== Valutazione
Una volta scelti i servizi per la valutazione, ho implementato una _Command Line Interface (CLI)_ per ottenere i risultati (attributi) dei tre modelli scelti e di _Bedrock Data Automation_ e salvarli in locale. Dopo aver utilizzato i servizi, sono stato in grado di confrontare le loro caratteristiche e i loro problemi, aspetto importante per la scelta finale del servizio migliore. Infine mi sono concentrato sui risultati ottenuti, comparando ciò che i modelli hanno generato con l'_output_ di _Bedrock Data Automation_, prima di decidere con quale servizio implementare l'_API_ finale.

=== Command Line Interface (CLI)
Lo scopo della _CLI_ è stato quello di avere un'interfaccia semplice con la quale generare gli attributi a partire da un'immagine o da un video, e salvarli su file per poterli successivamente confrontare. La _CLI_ è stata implementata in _Go_ e utilizza i _package_ offerti da _AWS SDK per Go_ #footnote[https://github.com/aws/aws-sdk-go-v2 (ultima visita 05/07/2025)] per interagire con i servizi di AWS, in particolare con _Bedrock_, _Data Automation_ e _S3_. \ 
La _CLI_ è composta da due programmi, uno per invocare i _VLM_ di _Bedrock_ e uno per invocare _Data Automation_. Questi programmi condividono la _business logic_ e la _persistence logic_, poichè entrambi utilizzano la logica per ricavare il contenuto da _S3_ e per salvare i risultati su file. \
In generale l'esecuzione è composta da 5 fasi:
+ _parsing_ e validazione delle _flag_ (opzioni) passate da linea di comando;
+ preparazione _input_ per i servizi;
+ chiamata _API_ ai servizi;
+ ottenimento dei risultati;
+ salvataggio dei risultati su file.

==== Application Logic
Nella parte di _application logic_ è stato implementato il _parsing_ e la validazione dell'_input_ passato tramite _flag_ (opzioni) quando si esegue il programma. \
Le _flag_ utilizzate sono:
- *_VLM_*
  - \-_uri_, per specificare l'identificativo (URI) del file immagine o video salvato su _S3_;
  - \-_mod_, per specificare il modello da utilizzare per la generazione degli attributi, "cl" per Claude Sonnet 3.7, "nova" per Nova Pro, "pix" per Pixtral Large e "all" per tutti e tre i modelli. A seconda del modello scelto, viene selezionato l'ID del modello da utilizzare per la chiamata _API_ ed il suo costo per _token_ di _input_ e _output_ #footnote[https://aws.amazon.com/bedrock/pricing/ (ultima visita 05/07/2025)]\;
  - \-_out_, per specificare il tipo di attributo da generare, "alt" per il testo alternativo, "key" per la lista di _keyword_ e "desc" per la descrizione #footnote[non c'era ancora l'opzione di generare tutti e tre gli attributi]. A seconda della tipologia di attributo da generare, viene selezionato il ruolo e il _prompt_ da utilizzare per la chiamata _API_;
  - \-_lan_, per specificare la lingua dell'_output_, "it" per l'italiano e "en" per l'inglese. A seconda della lingua scelta, viene aggiunta alla fine del _prompt_ la specifica della lingua;
- *_Data Automation_*
  - \-_uri_, per specificare l'identificativo (_URI_) del file immagine o video salvato su _S3_;
  - \-_type_, per specificare il tipo di contenuto, "img" per le immagini e "vid" per i video. A seconda della tipologia di file, viene selezionata la _blueprint_ adatta;
  - \-_lan_, per specificare la lingua dell'_output_, "it" per l'italiano e "en" per l'inglese. Viene salvato un parametro con la lingua scelta, servirà successivamente alla _business logic_.

==== Business Logic
All'interno della _business logic_ sono state implementate tutte le funzioni principali della _CLI_, in particolare quelle che gestiscono le chiamate _API_ ai servizi di AWS e quelle che comunicano con la _persistence logic_.
- _ConverseModel_: funzione che va a chiamare l'_API_ di _Bedrock_ con l'ID del modello scelto, i parametri, il ruolo, il _prompt_ ed il contenuto da processare;
- _StoreResults_: funzione che va a creare l'oggetto da salvare su file, a partire dai risultati dei modelli, e chiama la funzione della _persistence logic_ per il salvataggio;
- _UpdateBlueprint_: funzione che va ad aggiornare la _blueprint_ per _Data Automation_, in modo da modificare le istruzioni per specificare la lingua di _output_ scelta;
- _InvokeBDA_: funzione che va a chiamate l'_API_ di _Data Automation_ con i due identificativi di S3 (URI) per _input_ e _output_ (Data Automation salva direttamente i risultati su S3, nell'URI specificato). Questa chiamata è asincrona, quindi per sapere quando poter ricavare il risultato salvato su S3 vado a fare _polling_ sullo stato della chiamata, controllando periodicamente fino a che non restituisce "_JobStatusSuccess_" o un errore;
- _GetS3Object_: funzione che va ad utilizzare l'_API_ di _S3_ per ottenere un oggetto salvato in base al suo identificativo (URI). Questa funzione viene utilizzata sia per ottenere il file di _input_ da processare nel caso dei modelli di _Bedrock_ (tranne Nova Pro), sia per ottenere il file di _output_ generato da _Data Automation_;
- _StoreS3Result_: funzione che va a creare l'oggetto da salvare su file, a partire dal risultato di _Data Automation_ salvato su S3, e chiama la funzione della _persistence logic_ per il salvataggio.
\
Nella _business logic_ sono state implementate anche due funzioni per analizzare i risultati dei due servizi e ricavare alcune statistiche utili per la valutazione finale.

==== Persistence Logic
Nella _persistence logic_ troviamo le funzioni per salvare su file e leggere i risultati ottenuti dai servizi. Inoltre sono state aggiunte anche le funzioni per salvare e leggere i file di analisi relativi ai modelli e a _Data Automation_. \
Come tipologia di file è stato scelto _Newline-delimited JSON_ (.ndjson), in cui ogni riga corrisponde ad un valido JSON: questa scelta è stata fatta in modo da evitare di leggere tutto il file ogni volta che si aggiunge un nuovo risultato. \
\
Esempio di singolo risultato JSON:
- *_VLM_*
```json
{
    "input_path": "S3 URI del contenuto",
    "role": "ruolo utilizzato",
    "prompt": "prompt utilizzato",
    "temperature": "temperatura utilizzata",
    "top_p": "top P utilizzato",
    "s3_time": "tempo per ottenere il contenuto da S3",
    "results": [
        {
          "model": "ID del modello utilizzato",
          "description": "output del modello",
          "stop_reason": "motivo stop della generazione",
          "input_tokens": "numero di token in input",
          "output_tokens": "numero di token in output",
          "response_time": "tempo di risposta del modello",
          "approximately_cost": "costo approssimativo chiamata API"
        },
    ]
}
```
#pagebreak()
- *_Data Automation_*
```json
{
    "input_path": "S3 URI del contenuto",
    "bda_results": {
        "alt_attribute": "alt generato",
        "description": "descrizione generata",
        "keywords": {
            "objects": [
                "singola keyword per l'oggetto",
            ],
            "atmosphere": "keyword per l'atmosfera",
            "style": "keyword per lo stile",
            "color": "keyword per il colore",
            "angle": "keyword per l'angolazione"
        },
        "response_time": "tempo di risposta"
    }
}
```
\
=== Confronto servizi
In questa sezione vengono confrontati i modelli di _Bedrock_ e _Data Automation_, in base alle loro caratteristiche, al loro utilizzo, ai problemi riscontrati e alle decisioni prese per far fronte a questi problemi. L'idea è quella di fornire una visione d'insieme dei servizi prima di valutare i risultati ottenuti. \
\
#set par(justify: false)
#pad(left: -1in, right: -1in)[
  #figure(
    table(
      columns: (0.6fr, 2fr, 2.5fr),
      align: left,
      table.header(
        [], [*Modelli Bedrock*], [*Data Automation*]
      ),
      [*Vantaggi*],
      [
        - vasta scelta di modelli e aggiornamento continuo del catalogo
        - risultati personalizzabili (_prompt_ e parametri)
        - costi variabili a seconda del modello (possibile valutazione rapporto costo/risultato)
        - implementazione libera (fonte dell'_input_, destinazione dell'_output_)
        - interfaccia _API_ comune, permette di aggiungere un modello modificando poche righe di codice
      ],
      [
        - interfaccia di alto livello (implementazione semplice e non necessita di aggiornamenti manuali)
        - _input_ e _output_ collegati a _S3_, basta fornire gli identificativi (URI)
        - _standard output_ già fornito e facilmente personalizzabile da console AWS
        - costi fissi per _input_ (\$0.005 per ogni immagine e \$0.084/min per i video con _custom output_, cambia solo nel caso di _blueprint_ avente più di 30 campi)
        - riconoscimento automatico tipologia contenuto (documento, immagine, video, audio) e relativa _blueprint_
      ],
      [*Limiti*],
      [
        - vasta scelta di modelli → necessità di ricerca/studio per trovare il migliore rispetto al caso d'uso e può portare all'utilizzo di modelli non adatti al compito; l'aggiornamento continuo è a carico dello sviluppatore
        - risultati personalizzabili → maggiore rischio di ottenere risultati non voluti (_prompt_ scritto male, parametri non corretti, ecc.)
        - implementazione libera → a carico dello sviluppatore
        - interfaccia _API_ comune → non per tutti i modelli presenti nel catalogo (ad esempio non è supportata dai modelli che generano immagini #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-supported-models-features.html (ultima visita 05/07/2025)])
      ],
      [
        - interfaccia di alto livello → informazioni ridotte (modello utilizzato?) e possibilità di cambiamento limitata (no parametri, no scelta modello)
        - collegamento a _S3_ → contenuti in locale non utilizzabili
        - _standard output_ → non sempre sufficiente a seconda del caso d'uso
        - costi fissi per _input_ → non c'è la possibilità di pagare di meno/più per risultati meno/più precisi
        - riconoscimento automatico → non sempre corretto, ad esempio un file PNG può essere visto come documento o come immagine → possibilità di esplicitare come processare (immagine/documento) certe tipologie di file #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-routing-enablement.html (ultima visita 05/07/2025)], solamente se si utilizza un _project_ #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-projects.html (ultima visita 05/07/2025)]
      ],
      [*Problemi*],
      [
        - utilizzo di _InvokeModel API_ (scelta fatta inizialmente) → necessità di molto codice ausiliario dovuto a strutture di richiesta/risposta diverse per ogni modello
        - _Bedrock_ attualmente non offre alcuni dei modelli più forti sul mercato (_GPT_, _Gemini_) e alcuni sono disponibili solo in regioni specifiche (Stati Uniti)
        - Nova Pro unico modello attualmente (13/06/2025) disponibile in Europa che offre funzionalità _video-to-text_, quindi che accetta video in _input_ e genera testo
        - relativo al caso d'uso, pochi modelli (se non solo quelli di Amazon) accettano in _input_ l'identificativo (URI) diretto del contenuto salvato su _S3_
      ],
      [
        - le istruzioni fornite all'interno della _blueprint_ per il _custom output_ hanno un limite di lunghezza → non si può essere il più specifici possibile
        - se si utilizza un _project_, lo _standard output_ viene sempre generato #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-projects.html, "A project configured to generate custom output will also generate standard output automatically." \ (ultima visita 05/07/2025)] (in inglese), nonostante l'unico interesse sia in quello _custom_
        - l'unico modo per specificare la lingua in _output_ è cambiare le istruzioni della _blueprint_ tramite _API_ o console (la _blueprint_ rimane uguale all'ultima modifica fatta), senza costi ma comporta un tempo di attesa
        - supporta solo PNG/JPEG #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-limits.html \ (ultima visita 05/07/2025)] <bda-prerequisites> come formati per le immagini, e MP4/MOV @bda-prerequisites per i video
        - alcuni problemi riscontrati con i video, spiegati nella @video-evaluation
        - il servizio attualmente (20/06/2025) è disponibile solo negli Stati Uniti
      ],
      [*Decisioni*],
      [
        - cambiamento _API_ da _InvokeModel_ a _Converse_, supportata da tutti e tre i modelli scelti per la valutazione
        - aggiunta struttura per ricavare prima il contenuto da _S3_ e successivamente inviarlo al modello (Claude e Pixtral)
        - immagini e video vengono ricavati da _S3_ europeo e viene utilizzato il servizio in europa con _cross region inference_ #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html \ (ultima visita 05/07/2025)] (necessario per alcuni modelli)
      ],
      [
        - ridurre il _prompt_ originale in modo che sia entro i limiti di lunghezza delle istruzioni
        - selezionare come _standard output_ solamente la descrizione del contenuto, potenzialmente utile, e mantenerla solo nel caso in cui la lingua voluta sia l'inglese
        - prima di invocare il servizio viene aggiornata la _blueprint_ in modo da modificare le istruzioni e stabilire la lingua dell'_output_
        - sono state convertite tutte le immagini da formato WEBP in JPEG
        - immagini e video vengono ricavati da _S3_ (N. Virginia) e viene utilizzato il servizio in N. Virginia
      ]
    ),
    caption: [Confronto servizi]
  ) <service-comparison-table>
]
#set par(justify: true)

=== Valutazione immagini
==== Risultati
==== Analisi
==== Considerazioni

=== Valutazione video <video-evaluation>
==== Risultati
==== Analisi
==== Considerazioni
\