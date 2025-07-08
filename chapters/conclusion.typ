#pagebreak(to:"odd")

= Conclusioni
<cap:conclusioni>

#v(1em)
#text(style: "italic", [
    Valutazione degli obiettivi raggiunti, delle conoscenze acquisite e dell'esperienza generale del tirocinio
])

#v(1em)

== Raggiungimento degli obiettivi
La maggior parte degli obiettivi del progetto prefissati nel piano di lavoro sono stati raggiunti. \ Di seguito viene riportata una tabella con i requisiti e il loro stato (soddisfatto o meno): \
\
#figure(
  table(
    columns: (24%, auto, auto),
    align: (center + horizon, left + horizon),
    table.header(
      [#align(left)[*Tipologia*]], [*Requisito*], [#align(left)[*Soddisfatto*]]
    ),
    table.cell(rowspan: 3)[*Obbligatorio*],
    [sviluppo di una POC con le soluzioni identificate: focus sulla generazione a partire da un'immagine],
    [#text(size: 1.7em)[\u{1F5F8}]],
    [stesura di un documento di comparazione tra i modelli e funzionale],
    [#text(size: 1.7em)[\u{1F5F8}]],
    [applicazione della POC su test case definiti],
    [#text(size: 1.7em)[\u{1F5F8}]],
    table.cell(rowspan: 3)[*Desiderabile*],
    [POC: focus sulla generazione a partire da un prompt editabile],
    [#text(size: 1.7em)[\u{2717}]],
    [verifica di scalabilitá delle soluzioni],
    [#text(size: 1.7em)[\u{2717}]],
    [sviluppo di una CLI che permetta di usufruire della POC],
    [#text(size: 1.7em)[\u{1F5F8}]],
    table.cell(rowspan: 3)[*Facoltativo*],
    [POC: focus sulla generazione a partire da informazioni aggiuntive dei contenuti ed estensione ad altri tipi di contenuto],
    [#text(size: 1.7em)[\u{1F5F8}]#footnote[solamente estensione ad altri tipi di contenuto]],
    [calcolo costo delle soluzioni],
    [#text(size: 1.7em)[\u{1F5F8}]],
    [web service],
    [#text(size: 1.7em)[\u{1F5F8}]]
  ),
  caption: [Tabella finale requisiti.]
)
\
In generale, il tirocinio non ha seguito del tutto la pianificazione prestabilita nel piano di lavoro, poiché la ricerca dei servizi è durata meno del previsto e l'approfondimento tecnologico è stato portato avanti per quasi tutta la durata del progetto, dato che ci sono state due fasi implementative: la prima in cui è stata realizzata una _CLI_ per ottenere i risultati e valutare i servizi, e la seconda in cui è stata realizzata l'_API_ con il servizio scelto.

== Conoscenze acquisite
Grazie al tirocinio ho acquisito alcune conoscenze in vari ambiti: \
\
- *Teorico* → ho approfondito alcuni aspetti teorici riguardanti i _Large Language Models_ e la loro versione multimodale (_VLM_), come le tecniche di _prompt engineering_ e i parametri di inferenza per modificare la generazione dei risultati, ma anche le modalità di _benchmarking_ per valutare e confrontare i vari modelli. Questi sono argomenti che ancora mi affascinano e che sono grato di aver approfondito durante il tirocinio;
\
- *Tecnologico* → ho imparato ad utilizzare _Go_, un linguaggio di programmazione che non conoscevo, durante tutta la parte di sviluppo del progetto. Inoltre mi sono interfacciato per la prima volta con i servizi di AWS, specialmente con _Bedrock_ e _S3_, aspetto che ritengo molto utile in ambito lavorativo data la diffusione di AWS come fornitore di servizi _cloud_ nelle aziende;
\
- *Aziendale* → ho avuto la possibilità di essere inserito in un contesto lavorativo reale, con tutte le dinamiche e le problematiche che ne derivano. Ho partecipato attivamente a riunioni con i colleghi e ho conosciuto i vari aspetti di un'azienda come Thron, anche al di là della semplice parte di sviluppo. Questo mi ha permesso di comprendere che lo sviluppo software è solo una minima parte del lavoro svolto in un'azienda, e che ci sono molte altre attività utili ed essenziali per il corretto funzionamento di un prodotto o di un servizio.

== Valutazione personale
Il tirocinio presso Thron è stato un'esperienza formativa e interessante, che si è svolta senza problemi e in un clima molto positivo. Durante i due mesi trascorsi in azienda ho conosciuto molti colleghi giovani che hanno avuto il mio stesso percorso formativo, con cui ho potuto confrontarmi e scambiare idee. \ Devo in particolar modo ringraziare Dido, il mio tutor aziendale, il quale si è sempre dimostrato disponibile nei miei confronti, rispondendo a tutte le mie domande e aiutandomi a gestire al meglio le attività relative al progetto. \
\
Riguardo al progetto, sono soddisfatto del lavoro svolto e dei risultati ottenuti, ma se potessi tornare indietro, probabilmente mi concentrerei maggiormente sulla parte di studio delle tecnologie iniziale: un errore che ho commesso è stato quello di non approfondire a sufficienza le _API_ di _Bedrock_ e questo mi ha portato a non utilizzare fin da subito _Converse_, l'_API_ che fornisce un'interfaccia comune per invocare i modelli, ma a scoprire la sua esistenza solamente dopo aver già implementato la prima versione della _CLI_. Questa \"fretta\" ha causato un rallentamento dello sviluppo, poiché ho dovuto riscrivere parte del codice per utilizzare la nuova _API_, tempo che avrei potuto dedicare ad implementare alcune delle idee (@final-ideas) che ho avuto durante il progetto, ma che alla fine non sono riuscito a provare. \
\
Per concludere, ritengo che i temi trattati in questo tirocinio siano affascinanti e rilevanti per il periodo in corso, in cui i modelli di intelligenza artificiale stanno diventando sempre più diffusi e utilizzati in vari ambiti. \ Sono quindi grato di aver potuto svolgere un'attività di ricerca e sviluppo su un argomento così attuale e di cui mi sto appassionando sempre di più. 
