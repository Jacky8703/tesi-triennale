#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2"

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
  - \-_mod_, per specificare il modello da utilizzare per la generazione degli attributi, "cl" per Claude Sonnet 3.7, "nova" per Nova Pro, "pix" per Pixtral Large e "all" per tutti e tre i modelli. A seconda del modello scelto, viene selezionato l'ID per la chiamata _API_ ed il suo costo per _token_ di _input_ e _output_ #footnote[https://aws.amazon.com/bedrock/pricing/ (ultima visita 05/07/2025)]\;
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
- _InvokeBDA_: funzione che va a chiamate l'_API_ di _Data Automation_ con i due identificativi di S3 (URI) per _input_ e _output_ #footnote[Data Automation salva direttamente i risultati su S3, nell'URI specificato]. Questa chiamata è asincrona, quindi per sapere quando poter ricavare il risultato salvato su S3 vado a fare _polling_ sullo stato della chiamata, controllando periodicamente fino a che non restituisce "_JobStatusSuccess_" o un errore;
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
In questa sezione vengono confrontati i modelli di _Bedrock_ e _Data Automation_, in base ai loro vantaggi, ai loro limiti, ai problemi riscontrati e alle decisioni prese per far fronte a questi problemi. L'idea è quella di fornire una visione d'insieme dei servizi prima di valutare i risultati ottenuti. \
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
        - riconoscimento automatico → non sempre corretto, ad esempio un file PNG può essere visto come documento o come immagine → possibilità di esplicitare come processare (immagine/documento) certe tipologie di file #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-routing-enablement.html (ultima visita 05/07/2025)], solamente se si utilizza un _project_ #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-projects.html (ultima visita 05/07/2025)] <bda-project-footnote>
      ],
      [*Problemi*],
      [
        - utilizzo di _InvokeModel API_ (scelta fatta inizialmente) → necessità di molto codice ausiliario dovuto a strutture di richiesta e risposta diverse per ogni modello
        - _Bedrock_ attualmente (13/06/2025) non offre alcuni dei modelli più forti sul mercato (_GPT_, _Gemini_) e alcuni sono disponibili solo in regioni specifiche (Stati Uniti)
        - Nova Pro unico modello attualmente (13/06/2025) disponibile in Europa che offre funzionalità _video-to-text_, quindi che accetta video in _input_ e genera testo
        - relativo al caso d'uso, pochi modelli (se non solo quelli di Amazon) accettano in _input_ l'identificativo (URI) diretto del contenuto salvato su _S3_
      ],
      [
        - le istruzioni fornite all'interno della _blueprint_ per il _custom output_ hanno un limite di lunghezza → non si può essere il più specifici possibile
        - se si utilizza un _project_, lo _standard output_ viene sempre generato @bda-project-footnote (in inglese), nonostante l'unico interesse sia in quello _custom_
        - l'unico modo per specificare la lingua in _output_ è cambiare le istruzioni della _blueprint_ tramite _API_ o console (la _blueprint_ rimane uguale all'ultima modifica fatta), senza costi ma comporta un tempo di attesa
        - supporta solo PNG/JPEG #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-limits.html \ (ultima visita 05/07/2025)] <bda-prerequisites> come formati per le immagini, e MP4/MOV @bda-prerequisites per i video
        //- alcuni problemi riscontrati con i video, spiegati nella @video-evaluation
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
    caption: [Confronto servizi.]
  ) <service-comparison-table>
]
#set par(justify: true)
\
=== Valutazione immagini
Sono state scelte nove immagini rappresentanti vari contenuti appartenenti all'azienda (persone, oggetti, pubblicità, mostre ecc.) di ambiti differenti, caricate su _S3_ e usate come _input_ sia per i modelli, sia per il servizio _Data Automation_. \ 
\
Nel caso dei modelli è stato utilizzato ognuno (Claude Sonnet 3.7, Nova Pro, Pixtral Large), per ogni immagine, per ogni tipologia di _output_ (alt, _keyword_, descrizione) e per ogni lingua (italiano, inglese). \ Per _Data Automation_ invece è bastato utilizzare l'API una volta per ogni immagine e per ogni lingua, dato che all’interno di un singolo risultato sono presenti tutte e tre le tipologie di _output_.  \ I risultati sono stati poi salvati su file .ndjson separati. \
\
Una volta ottenuti tutti i risultati ho utilizzato la funzione per analizzare i dati e avere una stima sul costo medio, sul tempo medio e sulla lunghezza media della descrizione generata (solo sulla descrizione dato che l’alt deve essere corto come _best practice_ e le _keyword_ devono essere 10). \
\
Successivamente ho valutato in modo soggettivo i risultati ottenuti, confrontando l’_output_ generato da ogni modello e da _Data Automation_ per ogni attributo. Solo nel caso di indecisione mi sono basato anche sul costo o tempo della richiesta. Ho assegnato
un punto per ogni attributo in ogni lingua e ho riportato aspetti particolari o caratteristiche che notavo nelle risposte. \
\
Per la valutazione degli attributi mi sono basato su questi aspetti:
- alt → ho controllato quale fosse il più conciso e descrittivo, magari che utilizzasse alcune parole chiave collegabili all'immagine (per motivi di SEO);
- _keyword_ → ho pensato principalmente alla ricerca, quindi valutando quali parole fossero utili per ritrovare quel contenuto, e a quanto erano generali;
- descrizione → ho guardato quale fosse la più generale e completa, senza errori e che non sembrasse palesemente generata da un modello. Inoltre ho penalizzato le descrizioni troppo lunghe, con tanti dettagli e con una struttura della frase non comune.

==== Risultati
La valutazione soggettiva è stata fatta una prima volta con un _top-P_ alto (0.9) e una seconda volta con un _top-P_ basso (0.3). \ Dopo alcune prove con _top-P_ a 0.3, ho notato come i risultati dei modelli Claude Sonnet 3.7 e Pixtral Large non cambiassero in modo significativo, mentre Nova Pro sembrava modificare il lessico e semplificare le _keyword_, quindi ho deciso di rivalutare solamente i risultati di quest'ultimo e confrontarli con quelli della prima valutazione. \
\
I punteggi finali ottenuti sono: \
\
#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: left,
    table.header(
      [*2° (top-P = 0.3*)], [*Claude*], [*Nova*], [*Pixtral*], [*BDA*]
    ),
    [Alt], [7], [4], [6], [1],
    [Keyword], [8], [3], [2], [5],
    [Descrizione], [2], [2], [8], [6],
    [*Totale*], [*17*], [*9*], [*16*], [*12*]
  ),
  caption: [Tabella punteggi servizi immagini (top-P = 0.9).]
)
\
#figure(
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: chart
    
    chart.columnchart(
      (
        ([*Claude*], 7, 8, 2),
        ([*Nova*], 4, 3, 2),
        ([*Pixtral*], 6, 2, 8),
        ([*BDA*], 1, 5, 6),
      ),
      label-key: 0,
      value-key: (1, 2, 3),
      mode: "clustered",
      size: (11, 6),
      y-label: [Punteggio],
      y-tick-step: 1,
      labels: ([Alt], [Keyword], [Descrizione]),
      legend: (0, -0.6),
      bar-style: i => (
        fill: (
          if i == 0 { rgb("2196f3") }      // Alt
          else if i == 1 { rgb("4caf50") } // Keyword
          else { rgb("ff9800") }           // Description
        )
      )
    )
  }),
  caption: [Grafico punteggi servizi immagini (top-P = 0.9).]
)
\
#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: left,
    table.header(
      [*2° (top-P = 0.3*)], [*Claude*], [*Nova*], [*Pixtral*], [*BDA*]
    ),
    [Alt], [8], [3], [7], [0],
    [Keyword], [9], [3], [4], [2],
    [Descrizione], [3], [1], [7], [7],
    [*Totale*], [*20*], [*7*], [*18*], [*9*]
  ),
  caption: [Tabella punteggi servizi immagini (top-P = 0.3).]
)
\
#figure(
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: chart
    
    chart.columnchart(
      (
        ([*Claude*], 8, 9, 3),
        ([*Nova*], 3, 3, 1),
        ([*Pixtral*], 7, 4, 7),
        ([*BDA*], 0, 2, 7),
      ),
      label-key: 0,
      value-key: (1, 2, 3),
      mode: "clustered",
      size: (11, 6),
      y-label: [Punteggio],
      y-tick-step: 1,
      labels: ([Alt], [Keyword], [Descrizione]),
      legend: (0, -0.6),
      bar-style: i => (
        fill: (
          if i == 0 { rgb("2196f3") }      // Alt
          else if i == 1 { rgb("4caf50") } // Keyword
          else { rgb("ff9800") }           // Description
        )
      )
    )
  }),
  caption: [Grafico punteggi servizi immagini (top-P = 0.3).]
)
\
Come si può notare i punteggi sono soggettivi (dalla prima valutazione alla seconda ho cambiato solo i risultati di Nova Pro, tuttavia gli altri punteggi sono variati più di 9-7=2 punti), ma comunque si possono notare degli aspetti in comune: Claude 3.7 Sonnet sembra essere il migliore, specialmente nel ricavare _keyword_ e nel generare l’alt (dove anche Pixtral Large si è rilevato buono); riguardo le descrizioni invece Pixtral Large e _Data Automation_ hanno ottenuto i punteggi più elevati; Nova Pro d’altra parte è sempre stato valutato come il peggiore, nonostante abbia ottenuto qualche punto nel generare l’alt e le _keyword_.

==== Analisi
Premesse: 
- il tempo medio per ottenere la risposta di _Bedrock Data Automation_ è abbastanza elevato (22 secondi), è importante però ricordare che il servizio viene eseguito negli Stati Uniti e che i suoi risultati vengono caricati automaticamente su _S3_;
- ai tempi medi dei modelli c'è da sommare anche il tempo medio per ottenere il contenuto da _S3_ (mezzo secondo) nel caso di Claude e Pixtral (Nova lo ricava autonomamente);
- per il costo medio c'è da tenere conto che con una singola chiamata di _Data Automation_ si ottengono tutti e tre gli attributi richiesti, mentre per i modelli sono state fatte tre chiamate differenti;
- le chiamate fatte a Nova Pro sono molte più degli altri modelli perché è stato utilizzato come modello di prova, essendo quello che costa meno.
\
#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: left,
    table.header(
      [], [*Claude*], [*Nova*], [*Pixtral*], [*BDA*]
    ),
    [Chiamate API], [70], [113], [69], [22],
    [Costo medio (centesimi di dollaro)], [0.5], [0.2], [0.65], [0.5],
    [Tempio medio], [4s], [2s], [2s], [22s],
    [Lunghezza media descrizione (parole)], [103], [60], [84], [54],
  ),
  caption: [Tabella analisi risultati immagini.]
)
\
Da questa analisi è chiaro come il servizio meno costoso è _Data Automation_ insieme a Nova Pro e le descrizioni più lunghe sono state generate dai modelli Claude Sonnet 3.7 e Pixtral Large.

==== Considerazioni
- *Claude 3.7 Sonnet*:
  - migliore quando si tratta di intuire oggetti o scritte non complete, nonostante i parametri lo limitino in ciò;
  - solitamente non si sbilancia nell'identificare il sesso o la nazionalità di una persona (difetto);
  - descrizioni troppo lunghe e precise (risolvibile modificando il _prompt_);
- *Nova Pro*:
  - molto economico e veloce;
  - solitamente identifica il sesso di una persona;
  - risposte meno precise degli altri modelli, rimane fin troppo generale;
  - nelle descrizioni non sempre le frasi sono collegate in maniera naturale;
- *Pixtral Large*:
  - riesce a generalizzare bene stando preciso nei dettagli, ottima via di mezzo nelle descrizioni (è stato l’unico a riportare alcune scritte);
  - solitamente identifica il sesso di una persona;
  - utilizza una struttura della frase comune;
  - ogni tanto genera testo formattato (_markdown_);
  - non sono convinto che possa accettare in _input_ i parametri #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-mistral-pixtral-large.html#awsui-tabs-:r2v:-request-0-panel (ultima visita 06/07/2025)], quindi temperatura e top-P non modificano il risultato;
- *Data Automation*:
  - riesce a generalizzare bene nelle descrizioni, ma ipotizza molto (nonostante le informazioni siano presenti nell’immagine);
  - alt solitamente troppo corto e poco informativo;
  - _keyword_ troppo specifiche e solitamente si limita ad una singola parola.
\
In generale le _keyword_ relative allo stile e all'angolazione non le ho trovate troppo utili, servirebbe avere una lista predefinita da
cui scegliere in modo che siano più coerenti (anche in vista di un potenziale filtro), oppure sostituirle con altri aspetti di
un’immagine.

=== Valutazione video <video-evaluation>
Come nella valutazione delle immagini, sono stati scelti alcuni video appartenenti all'azienda, di lunghezza diversa e relativi ad ambiti differenti, caricati su _S3_ e usati come _input_ sia per Nova Pro che per il servizio _Data Automation_. Si è deciso di valutare solamente la lista di _keyword_ generate a partire dal video, quindi non è stato richiesto ai servizi di produrre un attributo alt o una descrizione. \
\
Nova Pro è stato l’unico modello di Bedrock utilizzato per la valutazione poiché offre la funzionalità _video-to-text_, essenziale per il caso d’uso. Il modello è stato utilizzato per generare la lista di _keyword_ in italiano e in inglese.\ _Data Automation_ invece ha avuto qualche problema nella gestione dei video, e il risultato ottenuto si limita alla lista di _keyword_ in inglese, solo per i video più corti. \
I risultati sono stati salvati su file _.ndjson_ separati, aventi le stesse strutture usate precedentemente, dato che l’_output_ è un
sottoinsieme di quello generato per le immagini. \
\
*Problemi Bedrock Data Automation con video input*
\
I problemi riscontrati con il servizio Bedrock Data Automation sono stati: \
\
- *Job "_InProgress_"* → utilizzando il _project_, come avevo fatto con le immagini, lo stato del _job_ è rimasto "_InProgress_" #footnote[https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/service/bedrockdataautomationruntime@v1.3.0/types#AutomationJobStatus (ultima visita 06/07/2025)] (Created → InProgress → Success, ServiceError/ClientError) per un paio d’ore prima di restituire \"_internal service error_\". Come prima cosa ho ricontrollato i prerequisiti @bda-prerequisites per l’utilizzo di _Data Automation_ e il video dato in _input_ rientrava nei limiti (18.2 MB, 11 secondi, MP4 con H.264 Codecs), poi ho ricontrollato il codice, in particolare che gli identificatori delle risorse (ARN) fossero corretti, e ho abilitato le notifiche su _EventBridge_ in modo da notare se qualche evento particolare venisse generato. Ho anche provato con un formato video diverso (MOV) ma nulla di tutto ciò è servito a risolvere il problema. \ Infine ho cambiato il codice e al posto di utilizzare il _project_, ho dato in _input_ direttamente la _blueprint custom_ che avevo creato per analizzare i video e in questo modo il _job_ ha terminato con stato "_Success_" e l’evento è arrivato nella coda _SQS_. Ovviamente utilizzando la _blueprint_ direttamente si perdono i vantaggi del _project_ come lo _standard output_ e il _routing_ manuale di come vengono processati i file in _input_;
\
- *Lingua* → _Data Automation_ con i video genera la lista di _keyword_ in inglese, nonostante aver specificato che devono essere in italiano nelle istruzioni della _blueprint_. Ho anche provato a riscrivere le istruzioni in italiano, ma il massimo che ha generato sono state alcune _keyword_ in italiano (non corretto) e altre rimaste in inglese. \ I tentativi fatti sono stati: 
  - \"The output must only have the keyword in italian, not in other languages.\";
  - \"Provide the output results in Italian only. Do not use any other languages.\";
  - \"After extracting the keywords, translate them into Italian.\";
\
- *Lunghezza video* → nonostante nei prerequisiti @bda-prerequisites di _Data Automation_ sia esplicitato come la massima lunghezza dei video possa essere di 120 minuti, il _job_ non termina con video lunghi 13/14 minuti (rimane “_InProgress_” per circa 40 minuti prima di restituire \"_internal service error_\"). Ho provato a comprimerli, anche se non necessario, al 60% e al 25% ma in entrambi i casi il _job_ non ha terminato. \ All’interno della console di _Data Automation_, se si dà in _input_ un video lungo, viene estratto automaticamente un segmento di almeno 5 minuti, in modo da diminuire il carico da processare. Allora ho provato con un video da 13 minuti segmentato e dopo 40 minuti di attesa la console ha restituito l’errore \"_Unable to generate result, please try again later  _\". Stesso tentativo lo ho fatto tramite _API_, specificando il segmento da processare, e il finale è stato il medesimo.

==== Risultati
Dato che _Data Automation_ è riuscito a generare risultati soltanto in inglese per 8 video su 10, la valutazione si è basata sul
confronto di questi anche per Nova Pro. \
_Data Automation_ si è rilevato migliore nel compito di generare una lista di _keyword_ a partire da un video (5/8 valutate in modo soggettivo), ma rimangono alcune considerazioni da fare dopo l’analisi.

==== Analisi
Premesse: 
- i tempi mostrati nella tabella sottostante sono quelli di durata dei video e risposta dei servizi convertiti in secondi;
- riguardo i costi, sono riportati quelli relativi a Nova Pro (approssimativi) in centesimi di dollaro, e quelli di _Data Automation_, il quale ha un costo costante di \$0.084/min (quindi 8.4/min per confronto, mi baso sul fatto che se il video dura meno di un minuto il costo rimane quello del minuto intero).
\
#pad(left: -1in, right: -1in)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto),
      align: left,
      table.header(
        [*Video*], [*Durata*], [*Risposta \ Nova*], [*Risposta \ BDA*], [*Costo \ Nova*], [*Costo \ BDA*]
      ),
      [4k_bag], [11s], [5.3s], [43s], [0.3], [8.4],
      [video_24SWTK67], [12s], [2.8s], [33s], [0.35], [8.4],
      [video_ceramic], [15s], [3.1s], [39s], [0.4], [8.4],
      [video_ceramic1], [15s], [3.2s], [38s], [0.4], [8.4],
      [lipoil_1x1_sito], [15s], [4s], [40s], [0.4], [8.4],
      [Video marmo campagna], [24s], [4.6s], [43s], [0.6], [8.4],
      [4k_hand_cream], [47s], [16s], [73s], [1.25], [8.4],
      [Camomilla_Franchising #footnote[in questo video i 3 minuti finali sono statici, rimane fisso su una scritta (per questo lo ho tagliato)]\ (tagliato)], [176s \ (2.56 min)], [25s], [68s], [4.7], [25.2],
      [Camomilla_Franchising (Completo)], [352s \ (5.52 min)], [23s], [62s], [4.7], [50.4],
      [The BEST Beauty Products], [781s \ (13.01 min)], [70s], [Errore], [21], [109.2 (\$1.09)],
      [videoplayback], [824s \ (13.44 min)], [65s], [Errore], [22], [117.6 (\$1.18)]
    ),
    caption: [Tabella analisi risultati video.]
  )
]
\
#align(center)[*Tempistiche risultati video*]
#figure(
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: plot

    let xlabels = (
        (1, [11s]), (2, [12s]), (3, [15s]), (4, [15s]), (5, [15s]), (6, [24s]), (7, [47s]), (8, [176s]), (9, [352s]), (10, [781s]), (11, [824s])
    )
    let ylabels = (
      (8, [8s]),
      (16, [16s]),
      (24, [24s]),
      (32, [32s]),
      (40, [40s]),
      (48, [48s]),
      (56, [56s]),
      (64, [64s]),
      (72, [72s]),
    )

    plot.plot(
      size: (11, 6),
      axis-style: "left",
      x-label: [*Durata*],
      y-label: [*Risposta*],
      x-tick-step: none,
      y-tick-step: none,
      x-ticks: xlabels,
      y-ticks: ylabels,
      x-min: 0.5,
      x-max: 11.5,
      y-min: 0,
      legend: (0, -0.8),
      y-grid: true,
      {
        plot.add(
          ((1, 5.3), (2, 2.8), (3, 3.1), (4, 3.2), (5, 4), (6, 4.6), (7, 16), (8, 25), (9, 23), (10, 70), (11, 65)),
          mark: "o",
          line: "spline",
          label: [Nova]
        )
        plot.add(
          ((1, 43), (2, 33), (3, 39), (4, 38), (5, 40), (6, 43), (7, 73), (8, 68), (9, 62)),
          mark: "o",
          line: "spline",
          label: [BDA]
        )
      }
    )
  }),
  caption: [Grafico tempistiche risultati video.]
)
\
La tabella mostra come _Bedrock Data Automation_ è molto più costoso rispetto a Nova Pro (5x circa, per i video lunghi), e anche come tempi di risposta è molto più lento → _Data Automation_ ha generato la risposta ad un video da 47 secondi in 73 secondi, mentre Nova Pro nello stesso tempo (70 secondi) ha generato la risposta al video da 13 minuti (\"The BEST Beauty Products\"). \
\
In generale, come si nota dal grafico, le tempistiche non mostrano un qualche tipo di relazione chiara, quindi non si può dedurre con precisione i tempi di risposta per un determinato video. Sicuramente, anche con queste poche prove, è ovvio come Nova Pro sia più veloce a generare la risposta rispetto a _Data Automation_.

==== Considerazioni
- *Nova Pro*:
  - è stato in grado di generare l’attributo richiesto per tutti i video, in tempi più che ragionevoli;
  - ha un costo insignificante rispetto a _Data Automation_;
  - è molto versatile e affidabile → accetta molte tipologie di file video #footnote[https://docs.aws.amazon.com/nova/latest/userguide/complete-request-schema.html \ (ultima visita 06/07/2025)] e si possono fornire in _input_ anche da locale, senza l’utilizzo di _S3_;
  - nella valutazione soggettiva dei risultati è stato penalizzato perché forniva _keyword_ troppo generali → cambiando _prompt_ e parametri si può sicuramente migliorare, basta scegliere una preferenza: _keyword_ più specifiche e precise, con il rischio di allucinazioni, oppure più generali e affidabili, ma che colgono meno dettagli particolari del video;
- *Data Automation*:
  - ha generato _keyword_ adatte al contesto del video e con particolari utili in ottica di utilizzo per la ricerca;
  - ha un costo \"elevato\" rispetto a Nova Pro e i tempi di risposta sono significativamente maggiori;
  - ha dei limiti sulle tipologie di file video in _input_ (MP4/MOV);
  - attualmente ha alcuni problemi con i video che non sono riuscito a risolvere, come la questione della lingua (non genera/traduce risultati nella lingua specificata) e il limite di durata dei video (fino a 6 minuti sembra funzionare, ma con più di 13 va in errore, anche da console).
\
Come per le immagini, le _keyword_ relative allo stile e all’angolazione non le ho trovate utili per valutare un risultato rispetto ad un
altro.

=== Scelta finale
In base al confronto dei servizi effettuato, ai risultati ottenuti dalle immagini, e in particolar modo ai problemi avuti con i video, la scelta finale del servizio è stata quella di utilizzare i _Visual Language Models_ di _Bedrock_ nell'implementazione dell'_API_.