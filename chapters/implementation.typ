== Implementazione API
L'implementazione dell'_API_ segue l'architettura _standard_ utilizzata dall'azienda, che prevede la separazione tra _application_, _business_ e _persistence_ logic. Per la _business_ e _persistence logic_, viene definita rispettivamente una _struct_ per ogni _service_ e per ogni _dal_ (_data access layer_): queste _struct_ sono composte da puntatori ai _client_ esterni utilizzati e possiedono dei metodi associati che implementano la logica principale del servizio e della persistenza dei dati. \ In questo modo i _service_ e i _dal_ sono isolati per funzionalità e indipendenti tra loro, facilitando la manutenzione e l'estendibilità del codice. \
\
Esempio di _struct_:
```go
type GenerativeTextAttributeService struct {
    bedrockRuntime  *bedrockruntime.Client
	  s3client  *s3.Client
	  generativeTextAttributeDal  *dal.GenerativeTextAttributeDal
}
```
\
Nel _main_ viene effettuato il _setup_ dell'_API_, andando a creare i _client_ dei vari servizi AWS (_Bedrock_, _S3_, _DynamoDB_) e i _service_/_dal_ utilizzati, importare le variabili di ambiente, impostare le rotte e avviare il _server_ tramite _Lambda runtime_ (AWS _Lambda_). Il _server_ rimane in ascolto per le richieste _Lambda_, nel mio caso specifico richieste HTTP effettuate a un _Lambda Function URL_, e le adatta in modo che _Gin_ gestisca il _routing_ e restituisca le risposte, anch'esse riadattate in un formato compatibile con _Lambda Function_. \
\
In generale, per ogni _layer_ sono state definite delle _struct_ che rappresentano i dati utilizzati:
- _DTO_ (_Data Transfer Object_) per l'_application logic_, che definiscono le strutture dei dati utilizzate per le richieste e le risposte dell'_API_;
- _domain_ per la _business logic_, che rappresentano i dati essenziali per il funzionamento del servizio, come gli ID dei modelli, i _prompt_, i parametri e i dati provenienti dagli altri _layer_ ;
- _DAO_ (_Data Access Object_) per la _persistence logic_, che definiscono le strutture dei dati salvati a livello di database, come gli attributi generati e i metadati associati.
Alcuni di questi dati devono necessariamente passare attraverso i vari _layer_ per essere processati, quindi sono stati implementati degli adattatori (_converter_) per convertire i dati e fare in modo che ogni componente utilizzi solamente le strutture a lui dedicate, evitando dipendenze dirette e isolando il più possibile ogni _layer_.

=== Application Logic
Nell'_application logic_ è stato implementato il _controller_ che definisce le rotte e i metodi associati per gestire le richieste HTTP. In particolare, l'_API_ espone tre rotte principali: \
\
- *POST* /content-generative-text-attribute-stage/generate → per generare un attributo a partire da un'immagine o da un video. Nel _body_ della richiesta viene specificato il tipo di attributo da generare (alt, _keyword_, descrizione o tutti e tre), la lingua in cui generarlo (italiano o inglese), il modello da utilizzare (Claude Sonnet 3.7, Nova Pro, Pixtral Large o tutti e tre) e il file da elaborare (identificativo dell'oggetto salvato su _S3_);
\
- *GET* /content-generative-text-attribute-stage/contents/:filename/attributes/:attributeCode/locale/:locale/model/:model → per ottenere un singolo attributo in base al nome del file (_filename_), al tipo di attributo (_attributeCode_), alla lingua (_locale_) e al modello (_model_). \ Oltre all'attributo, la risposta contiene anche l'ID del modello utilizzato per generarlo e l'identificativo del file su _S3_ (URI) da cui è stato generato; 
\
- *GET* /content-generative-text-attribute-stage/contents/:filename/attributes/:attributeCode/locale/:locale → per ottenere una lista di attributi in base al nome del file (_filename_), al tipo di attributo (_attributeCode_) e alla lingua (_locale_). \ Questa rotta è utile per ottenere tutti gli attributi dello stesso tipo e lingua, generati dai tre modelli per un determinato file, in modo da poterli confrontare e scegliere il migliore.
\
La validazione dei dati in _input_ avviene grazie a _Gin_, che permette di definire le regole di validazione (_binding tags_) direttamente nelle strutture dei dati utilizzate per le richieste (_DTO_).

=== Business Logic
La _business logic_ è la parte principale dell'_API_, in cui viene implementata la logica di generazione degli attributi. Per ogni richiesta viene ricavato il contenuto da elaborare (se necessario) tramite il _client_ di _S3_, e viene utilizzato il _client_ di _Bedrock_ per generare l'attributo richiesto con il modello selezionato. Infine, viene passato il risultato al _DAL_ (_Data Access Layer_) associato per salvare l'attributo generato nel database. \ Data la limitata complessità di questo servizio, ho implementato un unico _service_ che possiede i metodi per generare gli attributi richiesti e per ricavare i risultati salvati.

=== Persistence Logic
La _persistence logic_ si occupa di salvare gli attributi generati insieme ad altri metadati nel database ed estrarli quando richiesto. Come database è stato scelto _DynamoDB_, data la sua semplicità di utilizzo e la sua integrazione con i servizi AWS (non necessaria in questo progetto, ma utile per una futura implementazione da parte dell'azienda). \ 
In _DynamoDB_ ogni _record_ deve avere una chiave primaria univoca, e sono disponibili due tipologie: \
\
- *_Partition Key_* (semplice): una chiave primaria composta da un singolo attributo (1 colonna), che identifica in modo univoco ogni _record_;
\
- *_Partition Key_ + _Sort Key_* (composta): una chiave primaria composta da due attributi (2 colonne), in cui il primo identifica la partizione (unità fisica) dove viene salvato il _record_ e il secondo identifica l'ordinamento dei _record_ all'interno della stessa partizione.
\
Per il progetto è stato scelto di utilizzare una chiave primaria composta, in modo da poter salvare più attributi per lo stesso file e per filtrarli in base al tipo di attributo e alla lingua. Nello specifico, la _partition key_ è il nome del file (_filename_) e la _sort key_ è una combinazione del tipo di attributo, della lingua e del modello (_attributeCode\_locale\_model_). \
\
Il _DAL_ implementa tre metodi:
- _SaveAttributeToDB_ → per salvare un'istanza di _AttributeDao_ su _DynamoDB_.
```go
    type AttributeDao struct {
        Filename             string
        AttributeLocaleModel string
        Attribute            string
        Locale               string
        ModelID              string
        ObjectURI            string
        Value                string
    }
```
- _GetAttributeByModel_ → per ottenere un _record_ specifico in base alla chiave primaria composta (_filename_ e _attributeCode\_locale\_model_). \ Ritorna un'istanza di _AttributeDao_;
- _GetAttributes_ → per ottenere una lista di _record_ in base alla _partition key_ (_filename_) e alla _sort key_ che inizia con il tipo di attributo (_attributeCode_) e la lingua (_locale_). In questo modo non viene specificato il modello, e quindi si ottengono tutti gli attributi generati dai modelli per un determinato file. Ritorna una lista di istanze di _AttributeDao_.  