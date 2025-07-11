#pagebreak(to:"odd")

= Preliminari
<cap:preliminari>

#v(1em)
#text(style: "italic", [
    Concetti teorici fondamentali e tecnologie utilizzate
])

#v(1em)

== Large Language Models (LLM)
Modelli di intelligenza artificiale in grado di comprendere e generare testo in linguaggio naturale. In particolare, i _LLM_ si basano su reti neurali (algoritmi di _machine learning_) con miliardi di parametri, addestrate su enormi quantità di testo che le rendono in grado di apprendere i pattern e le strutture del linguaggio. Nonostante le loro varie applicazioni, i _LLM_ svolgono fondamentalmente un unico compito: predirre il _token_ successivo in una sequenza di testo, dove con _token_ si intende l'unità di testo più piccola che un modello è in grado di processare (parole, sillabe, lettere, ecc.). Per ogni sequenza di _token_, il modello determina una distribuzione di probabilità sui _token_ successivi, e il _token_ con la probabilità più alta viene scelto come successore. Questo processo di generazione del testo è noto come inferenza del modello.

== Visual Language Models (VLM)
Modelli di intelligenza artificiale che combinano la comprensione del linguaggio naturale (_LLM_) con la comprensione delle immagini/video. I _VLM_ utilizzano un codificatore visivo per estrarre le proprietà di un'immagine (colori, forme, struttura, ecc.) e le convertono in una rappresentazione numerica (_vector embedding_) che può essere elaborata da un modello di linguaggio, il quale viene usato per generare l'_output_ richiesto. Questi modelli sono definiti come multimodali, poiché sono in grado di ricevere in _input_ sia testo che immagini, rendendo possibile il loro utilizzo in compiti come il riconoscimento visivo, la generazione di descrizioni e l'identificazione di oggetti.

== Parametri di inferenza
Parametri che influenzano la scelta del _token_ successivo da parte di un _Large Language Model_ durante il processo di inferenza. Grazie a questi parametri è possibile decidere la casualità, la diversità e la precisione dell'_output_ generato. In generale, favorendo la scelta di _token_ più probabili il modello genera testo più accurato e prevedibile, ma con un lessico comune; viceversa favorendo i _token_ meno probabili il modello genera testo più creativo e vario, ma meno preciso. Di seguito sono elencati i principali parametri di inferenza:
#v(1em)
- *Temperatura* \ Parametro che influenza la distribuzione di probabilità dei _token_, aumentando o diminuendo il divario tra le probabilità dei _token_ più probabili e quelli meno probabili. Solitamente può assumere valori compresi tra 0 e 1, dove con un valore basso (tendente a 0) il divario viene aumentato, facilitando la scelta dei _token_ più probabili, mentre con un valore alto (tendente a 1) il divario viene ridotto, rendendo così possibile la scelta dei _token_ meno probabili;
\
- *Top-K* (sampling) \ Parametro che limita la scelta dei _token_ successivi a un sottoinsieme di quelli con le probabilità più alte. Il valore di K rappresenta il numero di _token_ da considerare. In altre parole, il modello considera nella scelta solo i K _token_ con le probabilità più alte e ignora gli altri;
\
- *Top-P* (nucleus sampling) \ Parametro che stabilisce la percentuale di _token_ candidati da considerare nella scelta del _token_ successivo. Assume valori tra 0 e 1, dove un valore di 0.9 indica che il modello considera solo i _token_ la cui somma delle probabilità raggiunge almeno il 90% della distribuzione totale. Le probabilità vengono successivamente ricalcolate in base al numero di _token_ considerati. Quindi con un valore di P basso, il modello sceglie tra i _token_ più probabili, mentre con un valore alto il modello considera un pool più ampio di _token_, aumentando la possibilità di scelta;
\
- *Lunghezza risposta* \ Parametro che limita il numero di _token_ generati dal modello in una singola risposta. Il suo valore indica il numero massimo di _token_ che il modello può generare, oltre il quale il processo di generazione si interrompe. Questo parametro è utile per evitare risposte troppo lunghe o per limitare la quantità di _token_ utilizzati per motivi di costo o prestazioni.

== Prompt Engineering
Attività di progettazione e creazione di _prompt_ (istruzioni testuali in linguaggio naturale) per produrre il miglior risultato possibile da un modello di intelligenza artificiale. Questa pratica è fondamentale poiché la qualità del _prompt_ influisce direttamente sulla qualità dell'_output_ generato dal modello. In generale, un buon _prompt_ deve essere il più specifico possibile, deve fornire il contesto della richiesta e deve essere formulato in modo chiaro e semplice. Inoltre è utile anche assegnare un ruolo al modello (_role prompting_), ad esempio chiedendo di comportarsi come un esperto in un determinato campo o come un assistente virtuale, per aumentare la coerenza nelle risposte o per stabilire uno stile di comunicazione specifico.

== Benchmarking
Processo di confronto sistematico fra le performance di diversi sistemi di intelligenza artificiale. Il confronto si basa su _benchmark_, ovvero un insieme di test che valutano le capacità dei modelli in compiti molto specifici. Un _benchmark_ utilizza un _dataset_ che può contenere un _training set_ e un _evaluation set_, dove il primo viene utilizzato per addestrare il modello per quel compito specifico (fornendo le risposte corrette) e il secondo per valutarne le performance su dati che non ha mai visto (una piccola percentuale rispetto al _training set_). Alcuni _benchmark_ non possiedono un _training set_, ma i modelli vengono valutati direttamente tramite l'_evaluation set_. I _benchmark_ sono utili per filtrare i modelli più performanti in determinati ambiti e per confrontare modelli diversi o versioni diverse dello stesso modello.

== Testo Alternativo (Alt Text)
Il testo alternativo è una breve descrizione testuale di un'immagine, necessaria per rendere il contenuto accessibile a persone che utilizzano tecnologie assistive come gli _screen reader_. Oltre al tema dell'accessibilità, il testo alternativo è utile anche per migliorare la SEO (_Search Engine Optimization_) di un sito web, poiché i motori di ricerca utilizzano queste descrizioni per comprendere il contenuto delle immagini e il contesto. In generale, il testo alternativo deve essere conciso e specifico, e deve essere inserito solamente nelle immagini che non sono puramente decorative.

== Tecnologie utilizzate
In questa sezione sono riportate le tecnologie utilizzate durante il progetto con le loro caratteristiche principali e il ruolo che hanno avuto. La maggior parte di esse sono state scelte poiché già adottate all'interno dell'azienda in cui si è svolto il tirocinio, garantendo così una maggiore integrazione con i sistemi esistenti e facilitando un possibile utilizzo futuro del progetto in produzione.

=== Go
_Go_ è un linguaggio di programmazione _open source_ sviluppato da Google, compilato e tipizzato staticamente. Soddisfa le esigenze della programmazione concorrente e possiede un sistema di _garbage collection_ che si occupa in modo autonomo della gestione della memoria. \ È stato l'unico linguaggio utilizzato per lo sviluppo del progetto, in particolare per lo sviluppo di una _CLI_ (_Command Line Interface_) e di un'_API_ (_Application Programming Interface_) per la generazione degli attributi.

=== Gin
_Gin_ è un _framework web_ per Go, progettato per essere leggero e veloce. Fornisce funzionalità per la gestione delle richieste HTTP, il _routing_, la gestione dei _middleware_ e la serializzazione dei dati. \ È stato utilizzato per implementare l'_API_ del progetto, in modo da generare gli attributi e ottenere i risultati tramite richieste HTTP.

=== AWS SDK per Go
Il _Software Development Kit_ (SDK) di AWS per _Go_ è un insieme di librerie che semplificano l'interazione con i servizi di _Amazon Web Services_ tramite il linguaggio Go, fornendo un livello di astrazione maggiore per facilitare lo sviluppo. \ È stato utilizzato come fonte di _package_ necessari per interagire con i servizi AWS utilizzati nel progetto.

=== AWS Bedrock
_Bedrock_ è un servizio di _Amazon Web Services_ (AWS) che offre un'ampia gamma di funzionalità relative ai modelli di intelligenza artificiale, in modo _serverless_, senza la necessità di gestire alcuna infrastruttura. \ Nel progetto sono state utilizzate le seguenti funzionalità per generare gli attributi testuali richiesti:
#v(1em)
- *_Foundation Models_* \ I modelli pre-addestrati (tra cui _LLM_ e _VLM_) di varie aziende, come Amazon, Meta e Anthropic, disponibili nel vasto catalogo offerto da _Bedrock_. Questi modelli possono essere utilizzati tramite un'unica _API_ e sono adatti a molti casi d'uso, come la generazione di testo, immagini e video brevi;
\
- *_Data Automation_* \ Servizio secondario di _Bedrock_ utilizzabile per estrarre e generare informazioni, tramite modelli di intelligenza artificiale, a partire da contenuti multimodali come documenti, immagini, video e audio.

=== AWS S3
_Amazon Simple Storage Service_ (S3) è un servizio di archiviazione di oggetti offerto da AWS, progettato per la scalabilità, la disponibilità e la sicurezza dei dati. \ È stato utilizzato per archiviare il _dataset_ di immagini e video da cui generare gli attributi testuali richiesti.

=== AWS DynamoDB
_DynamoDB_ è un servizio di database NoSQL _serverless_ completamente gestito da AWS, progettato per essere veloce e scalabile. \ È stato utilizzato per archiviare i metadati relativi agli attributi testuali generati dai modelli: nome del file immagine/video, tipologia di attributo, lingua dell'attributo, modello utilizzato per la generazione e l'attributo testuale generato.

=== AWS Lambda
_Lambda_ è un servizio che consente di eseguire codice all'interno dell'ambiente _cloud_ di AWS, senza dover effettuare il _provisioning_ delle risorse necessarie (memoria, CPU, rete, ecc.) o gestire i server. Il codice viene organizzato in funzioni Lambda, le quali vengono eseguite in risposta a eventi specifici, come richieste HTTP o eventi generati da altri servizi AWS. \ Nel progetto è stata creata una funzione Lambda con il codice per gestire le richieste HTTP dell'_API_, ed è stato fornito un URL pubblico da cui inviare le richieste.

=== AWS SQS
_Amazon Simple Queue Service_ (SQS) è un servizio di messaggistica offerto da AWS, che permette di inviare, ricevere e salvare i messaggi tra i componenti di un'applicazione in sistemi di code distribuite. \ È stato utilizzato per creare una coda di destinazione degli eventi generati da _Bedrock Data Automation_, in modo da poterli elaborare e controllare successivamente.

=== AWS EventBridge
_EventBridge_ è un servizio di AWS che permette di connettere i componenti di un'applicazione tramite eventi, facilitando la creazione di architetture _event-driven_. Con questo servizio è possibile elaborare gli eventi tramite _event bus_, _router_ che ricevono gli eventi da più fonti e li inoltrano a zero o più destinazioni, oppure tramite _pipes_ che ricevono gli eventi da un'unica fonte e li inoltrano ad una singola destinazione. \ È stato utilizzato per indirizzare gli eventi provenienti da _Bedrock Data Automation_ in una coda SQS.