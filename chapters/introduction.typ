// Non su primo capitolo
//#pagebreak(to:"odd")

= Introduzione

#v(1em)
#text(style: "italic", [
    Descrizione dell'azienda, del progetto di tirocinio e della struttura del documento
])

#v(1em)

== Azienda
Thron S.p.A #footnote[https://www.thron.com/it/] è un'azienda italiana, con sede a Piazzola sul Brenta (PD), che si occupa principalmente di _Digital Asset Management_ (DAM) e _Product Information Management_ (PIM). \ L'azienda offre una piattaforma in modalità _SaaS_ (_Software as a Service_), per controllare, gestire e distribuire su qualsiasi canale o sistema contenuti e informazioni di prodotto, evitando duplicazioni e perdite di dati. La piattaforma si occupa della vita a 360 gradi del contenuto, mettendo a disposizione degli utenti varie funzionalità per ottimizzarne la gestione e agevolare l'erogazione del prodotto su piattaforme di distribuzione esterne. \
\
L'azienda utilizza una metodologia di sviluppo _agile_, nello specifico _Scrum_, che prevede un ciclo di sviluppo iterativo e incrementale, con l'obiettivo di produrre avanzamenti misurabili in tempi brevi. Il lavoro viene svolto in _team_, suddivisi a seconda della loro specifica area di competenza (ad esempio contenuti, prodotti, ecc.), e diviso in periodi di tempo (_sprint_) solitamente di due settimane, durante i quali vengono pianificate le attività da svolgere (_sprint backlog_) e vengono svolte riunioni quotidiane (_daily meeting_) all'interno del _team_ per aggiornarsi sui progressi effettuati e sulle problematiche riscontrate. \ Ogni due settimane, inoltre vengono svolte riunioni denominate _Competence_, nelle quali si riuniscono tutti gli sviluppatori dell'azienda, divisi tra _front-end_ e _back-end_, per discutere di argomenti tecnici, condividere conoscenze e stabilire le linee guida di sviluppo da seguire. \
\
Durante il tirocinio sono stato inserito nel _team_ Contenuti e ho partecipato sia alle riunioni quotidiane che alle _Competence_ di _back-end_.

== Scopo tirocinio
All'interno della piattaforma di Thron è possibile gestire le informazioni e gli attributi dei contenuti salvati. In questo contesto si ha l'esigenza di andare a valorizzare determinati campi testuali per l'arricchimento dei contenuti, tra cui l'alt per un tema di accessibilità e SEO (_Search Engine Optimization_), la descrizione sia del contenuto che editoriale e una lista di _keyword_, per motivi di ricerca del contenuto. \
\
Lo scopo del tirocinio è quello di investigare quale strumento permetta di ottenere i migliori risultati di generazione di questi attributi testuali secondo criteri di _performance_, _privacy_ e costi. \ 
\
È prevista inoltre la realizzazione di una _POC_ (_Proof of Concept_) per provare lo strumento reputato più adatto e per inserirlo nel flusso di gestione dei contenuti.

== Organizzazione del testo
Il @cap:preliminari[capitolo] ha lo scopo di fornire brevemente le informazioni preliminari necessarie per comprendere il documento, quindi i concetti teorici fondamentali e le tecnologie utilizzate nel progetto. \
\
Il @cap:contributo-originale[capitolo] descrive le attività svolte durante il tirocinio, in ordine cronologico:
+ Ricerca → inizialmente è stata effettuata una ricerca dei servizi adatti al caso d'uso, all'interno dell'ambiente _cloud_ di AWS;
+ Valutazione → una volta trovati i servizi è iniziata la fase di generazione dei risultati e di valutazione, con l'obiettivo di capire quale fosse il servizio più adatto;
+ Implementazione _API_ → dopo la scelta finale, è stata implementata l'_API_ che andasse ad utilizzare il servizio scelto per generare i risultati;
+ Idee → infine ho riportato alcune idee che ho avuto durante lo sviluppo, ma che non sono riuscito a implementare per motivi di tempo. \
\
Nel @cap:conclusioni[capitolo] vengono riportate le conclusioni finali, con una valutazione degli obiettivi raggiunti rispetto al piano di lavoro, delle conoscenze acquisite e dell'esperienza generale del tirocinio.