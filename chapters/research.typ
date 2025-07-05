== Ricerca
Durante la prima parte del tirocinio ho svolto un'attività di ricerca per comprendere le tecnologie e i servizi adatti al caso d'uso del progetto, seguendo alcune linee guida decise insieme al tutor aziendale e al _product owner_ del team in cui sono stato inserito.

=== Contesto
Il tirocinio ha l'obiettivo di ricercare quale sia lo strumento migliore che permetta di generare automaticamente attributi testuali a partire da contenuti digitali. \ Durante la ricerca e lo sviluppo sono state adottate alcune linee guida:

- la ricerca degli strumenti (servizi) avviene all'interno dell'ambiente _cloud_ AWS, per compatibilità con l'infrastruttura aziendale;
- gli attributi testuali da generare sono un *testo alternativo* (_alt_), per motivi di accessibilità e SEO, una lista di *_keyword_*, per motivi di ricerca, e una *descrizione* generale del contenuto;
- l'alt deve seguire le _best practice_ #footnote[#box[https://www.accessibilitychecker.org/guides/alt-text/#anchor3 (ultima visita 05/07/2025)]] (conciso, descrittivo e rilevante);
- la lista di _keyword_ deve avere un numero limitato (10) ed è stato deciso di dividerle per categoria (6 sugli oggetti, 1 sullo stile, 1 sull'inquadratura, 1 sul colore principale, 1 sull'atmosfera);
- la descrizione deve rimanere generale, con un limite di lunghezza (120 parole);
- deve essere definito un _prompt_ specifico per tipo di attributo da generare, in modo da essere il più specifici possibile nella spiegazione del compito e migliorare i risultati;
- deve essere possibile specificare in _input_ quale dei tre attributi si voglia generare, con anche la possibilità di generarli tutti in un'unica richiesta;
- deve essere possibile specificare in _input_ quale dei tre modelli si voglia utilizzare, con anche la possibilità di utilizzarli tutti in un'unica richiesta;
- deve essere possibile specificare in _input_ la lingua (italiano/inglese) dell'output generato;
- deve essere possibile specificare in _input_ il contenuto da cui ricavare gli attributi.

=== Opzioni
*_Bedrock_* è stato il primo servizio preso in considerazione, dato che offre vari _VLM_ di aziende differenti, adatti al caso d'uso. \ Il primo passo è stato ricercare i tre modelli migliori nell'ambito di _image recognition_ tra quelli ovviamente multimodali (_VLM_), quindi che sono in grado di comprendere un'immagine e generare testo a partire da essa (_image-to-text_), e presenti nel catalogo europeo #footnote[il catalogo dei modelli disponibili varia a seconda della regione abilitata nell'account AWS] (_eu-west-1_). Inizialmente mi sono basato su _benchmark_ come _MMMU (Massive Multi-discipline Multimodal Understanding)_ #footnote[https://mmmu-benchmark.github.io (ultima visita 05/07/2025)] avente un _dataset_ che copre varie discipline (arte, scienza, medicina, ecc.), utile per filtrare i _VLM_ migliori, ma che non aveva molte corrispondenze con il catalogo europeo di _Bedrock_. \ Una piattaforma che ho utilizzato è stata LMArena #footnote[https://lmarena.ai/how-it-works (ultima visita 05/07/2025)], in cui la _leaderboard_ si basa su utenti che inseriscono un _prompt_ e scelgono la migliore risposta data da modelli anonimi, in modo da ottenere una valutazione imparziale basata solo sull'_output_ generato. Purtroppo solo la valutazione dell'utente è imparziale, poichè è stato fatto uno studio @singh2025leaderboardillusion che dimostra come la piattaforma non è imparziale rispetto alla scelta dei modelli da offrire per la generazione dei risultati. In particolare, LMArena ha favorito aziende come OpenAI e Google fornendo ai loro modelli circa il 40% dei _prompt_ totali inseriti dagli utenti, andando così ad aumentare la posizione dei modelli nella _leaderboard_, e viceversa penalizzava i modelli _open source_, i quali ottenevano una piccola percentuale dei _prompt_ inseriti. \
Da questa prima scrematura i modelli selezionati per la fase di valutazione sono stati: *Claude Sonnet 3.7* di Anthropic, *Pixtral Large* di Mistral AI e *Amazon Nova Pro* di Amazon. \
\
*_Data Automation_* è un servizio secondario di _Bedrock_ che serve per estrarre e generare informazioni a partire da contenuti multimodali quali documenti, immagini, video e audio. Le informazioni da estrarre possono essere scelte tra alcune opzioni di _default_ ma è anche possibile richiederne di personalizzate. Questo servizio è adatto al caso d'uso e quindi lo ho aggiunto tra quelli da valutare. \
\
*_Rekognition_* è un altro servizio AWS che ho considerato poiché permette di analizzare immagini o video e restituire alcune etichette relative al contenuto. Questo servizio però non è stato valutato dato che il suo utilizzo principale è quello di verificare i contenuti (rilevare contenuti inappropriati, identità online) o riconoscere volti/persone e restituisce solamente etichette prestabilite (potenzialmente utile per la lista di _keyword_ ma non per gli altri attributi). Oltre a questo mi ha dato l'impressione di essere un servizio obsoleto con l'uscita dei _VLM_, che sono molto più versatili.
#pagebreak()
=== Prompt, parametri e blueprint
Oltre al modello, un aspetto fondamentale per ottenere i risultati desiderati è il _prompt_. Mi sono informato tramite una guida #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-engineering-guidelines.html (ultima visita 05/07/2025)] fornita da AWS, che presenta alcuni consigli dati dalle aziende che sviluppano i modelli. In generale, per scrivere un _prompt_ è importante essere il più specifici possibile e dare il contesto della richiesta (l'_output_ a cosa servirà?). Per fare ciò è possibile fornire anche un ruolo al modello (_role prompting_): in questo modo, ancora prima di avere la richiesta, il modello è già a conoscenza del dominio di interesse; inoltre grazie al ruolo si può limitare lo spettro di generazione e fornire delle regole precise da seguire nel rispondere alla richiesta #footnote[https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/system-prompts#why-use-role-prompting (ultima visita 05/07/2025)]. \
\
Altri parametri che possono modificare la generazione dei modelli, in particolare la precisione della risposta, sono la temperatura, il top-P e il top-K:
- temperatura bassa → aumenta la probabilità dei _token_ più probabili e diminuisce la probabilità dei _token_ meno probabili → aumenta il divario della probabilità tra i _token_, facilitando la scelta del _token_ più probabile;
- top-P basso → rimuove i _token_ con probabilità bassa → solo i _token_ con alta probabilità vengono considerati (top P% della distribuzione, _token_ le cui probabilità sommate raggiungono almeno P%);
- top-K → stesso concetto di top-P, solo che nella scelta del _token_ successivo tiene in considerazione i K _token_ con probabilità maggiore.
\
Durante la valutazione ho utilizzato i parametri di temperatura e top-P, senza parametro top-K per due motivi: 
+ la funzione di top-P e top-K è la stessa, gestita in modo diverso, quindi usarli entrambi non porta a cambiamenti significativi nella generazione;
+ l'_API_ utilizzata per invocare i modelli (_Converse_ #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-call.html (ultima visita 05/07/2025)]) non possiede top-K all'interno del set base di parametri (_inferenceConfig_); per poterlo aggiungere andrebbe specificato nel campo "_AdditionalModelRequestFields_" ma i modelli utilizzano nominativi diversi per questo parametro (Claude "top_k", Nova "topK") e non tutti lo possiedono, quindi viene meno l'utilità di usare un'interfaccia comune per l'_API_, se deve essere modificata a seconda dei modelli utilizzati.
\
L'ultimo parametro di cui tenere conto è la lunghezza della risposta, quindi il massimo numero di _token_ che il modello può generare, ed essendo che gli attributi richiesti hanno un limite di lunghezza e devono essere concisi, ho deciso che non servisse avere un limite di _token_ elevato (max 256). \
\
Per la gestione della lingua viene aggiunto alla fine di ogni _prompt_: \"The text needs to be in "language"\", in modo che la risposta generata dal modello sia nella lingua corretta.
#pagebreak()
In generale i _prompt_ e i parametri li ho scelti in modo che il modello fosse il più affidabile possibile sulle risposte generate (temperatura = 0.001 e top-P = 0.3), specificando che descrivesse solo ciò che era presente nel contenuto, senza interpretazioni. Tuttavia questo comporta anche alcuni svantaggi, come un lessico semplice e non sempre adatto al contesto, oltre al fatto che il modello fa più fatica ad intuire e riportare informazioni incomplete (ad esempio del testo tagliato nell'immagine). \
Ovviamente i _prompt_ sono stati scritti in inglese #footnote[https://kubie.medium.com/stop-prompting-in-your-native-language-if-its-not-english-here-s-why-it-s-costing-you-9a927a2e408d (ultima visita 05/07/2025)]. \
\
#pad(left: -1in, right: -1in)[
  #figure(
    table(
      columns: (0.7fr, 2fr, 2.6fr),
      align: left,
      table.header(
        [*Attributo*], [*Ruolo*], [*Prompt*]
      ),
      [Testo \ alternativo (alt)],
      [You are an expert in web accessibility, SEO, and image analysis. Your task is to analyze images and generate high-quality alternative text (alt attributes) that are concise, descriptive, and context-aware. Your responses should follow best practices for alt text writing, ensuring accessibility for screen readers and alignment with web content context.],
      [Generate the best alt attribute for this image. Describe the essential content and purpose of the image, but be concise, you need to stay under 125 characters. Avoid phrases like \"image of\" or \"photo of\" unless contextually necessary. Output only the alt attribute.],
      [Keyword],
      [You are a visual content analyst and metadata specialist. Your task is to analyze an image and extract high-quality, concise keywords for image indexing and search optimization. You understand visual elements, moods, photographic techniques, and stylistic trends.],
      [Study this image and generate a list of relevant keywords to optimize it for search and discoverability. Generate up to 10 keywords, never more. The list needs to include: up to 6 visual objects clearly present in the image, 1 keyword to describe the mood or atmosphere, 1 keyword for the visual or artistic style, 1 keyword for the dominant colors, 1 keyword for the photo framing or angle. Use lowercase, comma-separated values. Do not include uncertain or speculative terms. Output only the final keyword list.],
      [Descrizione],
      [You are a visual description expert trained in media annotation and content understanding. Your task is to observe images and write concise yet complete descriptions that objectively detail what is visibly present in the image.],
      [Generate a general description of the image in under 120 words. Use natural language, not a list. Mention all clearly visible elements: objects, people, actions, settings, backgrounds, animals, etc. Use neutral tone, without interpretation or emotional framing (unless it's visually obvious). Include relevant spatial relationships (e.g., \"a woman standing next to a bicycle\"). Do not speculate about identity, time period, or unseen elements, describe only what you are sure of. Output only the final description.]
    ),
    caption: [Ruolo e _prompt_ per modelli Bedrock.]
  ) <prompt-bedrock-table>
]
#pagebreak()
Per quanto riguarda *_Data Automation_*, essendo la sua funzionalità quella di estrarre informazioni, non si basa su _prompt_ o parametri come i modelli offerti da Bedrock, ma su un meccanismo di _standard output_ e _custom output_: \
\
- *_standard output_* #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-standard-output.html \ (ultima visita 05/07/2025)] è l'_output_ predefinito che viene estratto dai contenuti (documenti, immagini, video e audio) ed è personalizzabile solamente nei limiti offerti dal servizio; ad esempio per le immagini è possibile avere in _output_ un riassunto e una lista di etichette riconosciute, non generate ma presenti all'interno di _IAB taxonomy_ #footnote[https://github.com/InteractiveAdvertisingBureau/Taxonomies/blob/develop/Content%20Taxonomies/Content%20Taxonomy%203.1.tsv (ultima visita 05/07/2025)]\; \
\
- *_custom output_* #footnote[https://docs.aws.amazon.com/bedrock/latest/userguide/bda-custom-output-idp.html (ultima visita 05/07/2025)] è l'output personalizzabile dall'utente tramite una struttura contenente le istruzioni su ciò che deve essere estratto dal contenuto (si possono pensare come _mini-prompt_ per ogni attributo da estrarre); questa struttura è chiamata *_blueprint_*, e permette di stabilire lo schema di informazioni ricavate. 
\
Grazie al _custom output_ quindi sono stato in grado di creare una _blueprint_ apposita per il caso d'uso e ho specificato le istruzioni che il servizio deve seguire per ricavare gli attributi testuali. \
\
Come per il _prompt_ dei modelli, la gestione della lingua avviene aggiungendo alla fine di ogni istruzione: \"The text needs to be in "language"\", in modo che gli attributi siano nella lingua corretta. \
\
Oltre alle istruzioni, l'unico parametro personalizzabile è il modo di estrarre i dati, che può essere "_Explicit_", quindi ricavato in modo esplicito solamente dai dati presenti nel contenuto, oppure "_Inferred_", tramite deduzione dai dati (più intuitivo). \
\
La _blueprint_ utilizzata è la seguente: \
\
- *Alt* (_Explicit_): \"Generate the best alternative text (alt attributes) for this image. Describe the essential content and purpose of the image, but be concise, you need to stay under 125 characters. Avoid phrases like 'image of' or 'photo of' unless contextually necessary.\"; \
\
- *Description* (_Explicit_): \"Generate a general description of the image in under 120 words. Mention all clearly visible elements. Use neutral tone, without interpretation or emotional framing. Do not speculate about identity, time period, or unseen elements, describe only what you are sure of.\"; \
\
- *Keyword*#footnote[oggetto composto da più campi, ognuno con la sua istruzione]: \"Your task is to analyze the image and extract high-quality, concise keywords for image indexing and search optimization. Generate a list of relevant keywords, up to 10 keywords, never more. Do not include uncertain or speculative terms.\"
  - Objects (_Explicit_): \"Extract six different keywords about objects clearly present in the image\";
  - Atmosphere (_Inferred_): \"Extract one keyword to describe the mood or atmosphere of the image\";
  - Style (_Inferred_): \"Extract one keyword to describe the visual or artistic style of the image\";
  - Color (_Explicit_): \"Extract one keyword to describe the dominant color and its tone in the image\";
  - Angle (_Inferred_): \"Extract one keyword to describe the photo framing or angle in the image\".
\
I _prompt_ e la _blueprint_ riportati sono riferiti alle immagini, per i video ho utilizzato gli stessi solamente sostituendo "image" con "video". \
\
