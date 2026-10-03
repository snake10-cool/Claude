import '../models/lehrplan.dart';

String _wasHeisst(String wort) => 'Was heißt "$wort" auf Englisch?';

final englisch = <Stufe, List<Thema>>{
  Stufe.vs1: [
    Thema.paare('e1-farben', 'Colours – Farben', {
      'rot': 'red', 'blau': 'blue', 'gelb': 'yellow', 'grün': 'green',
      'schwarz': 'black', 'weiß': 'white', 'orange': 'orange',
      'rosa': 'pink', 'braun': 'brown', 'lila': 'purple',
    }, _wasHeisst),
    Thema.paare('e1-zahlen', 'Numbers 1–10', {
      '1': 'one', '2': 'two', '3': 'three', '4': 'four', '5': 'five',
      '6': 'six', '7': 'seven', '8': 'eight', '9': 'nine', '10': 'ten',
    }, (z) => 'Wie heißt die Zahl $z auf Englisch?'),
  ],
  Stufe.vs2: [
    Thema.paare('e2-tiere', 'Animals – Tiere', {
      'Hund': 'dog', 'Katze': 'cat', 'Maus': 'mouse', 'Pferd': 'horse',
      'Vogel': 'bird', 'Fisch': 'fish', 'Kuh': 'cow', 'Schwein': 'pig',
      'Hase': 'rabbit', 'Ente': 'duck', 'Bär': 'bear', 'Löwe': 'lion',
    }, _wasHeisst),
    Thema.paare('e2-schule', 'School things', {
      'Buch': 'book', 'Stift': 'pen', 'Bleistift': 'pencil',
      'Schultasche': 'schoolbag', 'Lineal': 'ruler', 'Radiergummi': 'rubber',
      'Tisch': 'desk', 'Stuhl': 'chair', 'Tafel': 'board',
      'Lehrerin': 'teacher',
    }, _wasHeisst),
  ],
  Stufe.vs3: [
    Thema.paare('e3-familie', 'Family – Familie', {
      'Mutter': 'mother', 'Vater': 'father', 'Schwester': 'sister',
      'Bruder': 'brother', 'Oma': 'grandma', 'Opa': 'grandpa',
      'Tante': 'aunt', 'Onkel': 'uncle', 'Baby': 'baby',
      'Cousin': 'cousin',
    }, _wasHeisst),
    Thema.paare('e3-essen', 'Food – Essen', {
      'Apfel': 'apple', 'Brot': 'bread', 'Milch': 'milk', 'Käse': 'cheese',
      'Ei': 'egg', 'Wasser': 'water', 'Banane': 'banana',
      'Kuchen': 'cake', 'Saft': 'juice', 'Nudeln': 'noodles',
      'Erdbeere': 'strawberry',
    }, _wasHeisst),
    Thema.paare('e3-tage', 'Days of the week', {
      'Montag': 'Monday', 'Dienstag': 'Tuesday', 'Mittwoch': 'Wednesday',
      'Donnerstag': 'Thursday', 'Freitag': 'Friday', 'Samstag': 'Saturday',
      'Sonntag': 'Sunday',
    }, _wasHeisst),
  ],
  Stufe.vs4: [
    Thema.paare('e4-koerper', 'Body – Körper', {
      'Kopf': 'head', 'Hand': 'hand', 'Fuß': 'foot', 'Auge': 'eye',
      'Ohr': 'ear', 'Nase': 'nose', 'Mund': 'mouth', 'Bein': 'leg',
      'Arm': 'arm', 'Haare': 'hair', 'Zahn': 'tooth',
    }, _wasHeisst),
    Thema.paare('e4-monate', 'Months – Monate', {
      'Jänner': 'January', 'Februar': 'February', 'März': 'March',
      'April': 'April', 'Mai': 'May', 'Juni': 'June', 'Juli': 'July',
      'August': 'August', 'September': 'September', 'Oktober': 'October',
      'November': 'November', 'Dezember': 'December',
    }, _wasHeisst),
    Thema.liste('e4-iam', 'I am, you are, he is', [
      'I ___ ten years old.|am|is|are|be',
      'She ___ my friend.|is|am|are|be',
      'We ___ in the garden.|are|is|am|be',
      'You ___ very nice.|are|is|am|be',
      'It ___ a cat.|is|are|am|be',
      'They ___ at school.|are|is|am|be',
      'He ___ tall.|is|am|are|be',
    ]),
  ],
  Stufe.ms1: [
    Thema.liste('e5-simple', 'Present simple', [
      'He ___ football every day.|plays|play|playing|is play',
      'I ___ to school by bus.|go|goes|going|am go',
      'She ___ TV in the evening.|watches|watch|watchs|watching',
      'We ___ like spinach.|don\'t|doesn\'t|not|isn\'t',
      'My dad ___ coffee.|doesn\'t drink|don\'t drink|not drinks|doesn\'t drinks',
      '___ you like pizza?|Do|Does|Are|Is',
      '___ she live in Linz?|Does|Do|Is|Are',
      'Tom ___ his homework after school.|does|do|dos|doing',
    ]),
    Thema.liste('e5-havegot', 'have got / has got', [
      'I ___ a sister.|have got|has got|am got|have gets',
      'She ___ a new phone.|has got|have got|is got|has get',
      '___ you got a pet?|Have|Has|Do|Are',
      'He ___ any brothers.|hasn\'t got|haven\'t got|isn\'t got|don\'t got',
      'We ___ a big garden.|have got|has got|are got|have get',
    ]),
    Thema.paare('e5-plural', 'Irregular plurals', {
      'child': 'children', 'man': 'men', 'woman': 'women', 'foot': 'feet',
      'tooth': 'teeth', 'mouse': 'mice', 'person': 'people',
      'sheep': 'sheep', 'fish': 'fish', 'knife': 'knives',
    }, (w) => 'What is the plural of "$w"?'),
  ],
  Stufe.ms2: [
    Thema.paare('e6-irregular', 'Irregular verbs (past)', {
      'go': 'went', 'see': 'saw', 'eat': 'ate', 'drink': 'drank',
      'buy': 'bought', 'think': 'thought', 'take': 'took', 'come': 'came',
      'write': 'wrote', 'swim': 'swam', 'run': 'ran', 'make': 'made',
      'get': 'got', 'find': 'found', 'catch': 'caught',
    }, (v) => 'Simple past of "$v"?'),
    Thema.liste('e6-progressive', 'Simple or progressive?', [
      'Look! The baby ___.|is sleeping|sleeps|sleep|slept',
      'I usually ___ my bike to school.|ride|am riding|rides|riding',
      'Listen! Someone ___ the piano.|is playing|plays|play|played',
      'She ___ her grandma every Sunday.|visits|is visiting|visit|visiting',
      'Right now we ___ English.|are learning|learn|learns|learning',
      'Water ___ at 100 degrees.|boils|is boiling|boil|boiling',
    ]),
    Thema.liste('e6-compare', 'Comparisons', [
      'An elephant is ___ than a dog.|bigger|more big|biggest|big',
      'This is the ___ day of the year.|hottest|hotter|most hot|hot',
      'Maths is ___ than art.|more difficult|difficulter|most difficult|difficultest',
      'She is the ___ girl in class.|tallest|taller|most tall|tall',
      'My bike is ___ than yours.|better|gooder|best|more good',
      'This is the ___ film I have ever seen.|worst|baddest|worse|most bad',
    ]),
  ],
  Stufe.ms3: [
    Thema.liste('e7-perfect', 'Present perfect or past simple?', [
      'I ___ to London last year.|went|have gone|have been going|go',
      'She ___ her homework yet.|hasn\'t finished|didn\'t finish|doesn\'t finish|not finished',
      'We ___ that film twice.|have seen|saw|seen|have saw',
      '___ you ever ___ sushi?|Have … eaten|Did … eat|Have … ate|Do … eat',
      'He ___ his leg yesterday.|broke|has broken|has broke|breaks',
      'I ___ here since 2020.|have lived|lived|live|am living',
    ]),
    Thema.liste('e7-future', 'will or going to?', [
      'Look at those clouds! It ___ rain.|is going to|will|going|is will',
      'I think Austria ___ win the match.|will|is going to|goes to|winning',
      'We have bought tickets. We ___ see a concert.|are going to|will|go to|going',
      'The phone is ringing. – I ___ answer it!|\'ll|am going to|going to|answer',
      'Maybe it ___ snow tomorrow.|will|is going to|snows|snowing',
    ]),
    Thema.liste('e7-someany', 'some or any?', [
      'Have you got ___ brothers?|any|some|a|many',
      'I would like ___ tea, please.|some|any|a|many',
      'There isn\'t ___ milk left.|any|some|a|many',
      'Can I have ___ biscuits?|some|any|a|much',
      'We didn\'t see ___ animals.|any|some|a|much',
    ]),
  ],
  Stufe.ms4: [
    Thema.liste('e8-if', 'If-clauses', [
      'If it rains, we ___ at home.|will stay|would stay|stayed|stay will',
      'If I ___ rich, I would buy a horse.|were|am|will be|would be',
      'If you heat ice, it ___.|melts|would melt|melted|is melt',
      'If she ___ harder, she would pass.|studied|studies|will study|study',
      'I would help you if I ___ time.|had|have|will have|would have',
      'If we hurry, we ___ the bus.|will catch|would catch|caught|catches',
    ]),
    Thema.liste('e8-passive', 'Passive voice', [
      'English ___ all over the world.|is spoken|speaks|is speaking|spoken',
      'The house ___ in 1900.|was built|built|is build|was build',
      'The letters ___ every morning.|are delivered|deliver|are deliver|delivered',
      'My bike ___ yesterday.|was stolen|stole|is stolen|was stole',
      'The new school ___ next year.|will be opened|will open|is opened|opens',
    ]),
    Thema.liste('e8-reported', 'Reported speech', [
      'She said: "I am tired." → She said that she ___ tired.|was|is|were|be',
      'Tom said: "I like pizza." → Tom said that he ___ pizza.|liked|likes|like|is liking',
      'They said: "We will come." → They said that they ___ come.|would|will|shall|are',
      'He said: "I can swim." → He said that he ___ swim.|could|can|may|will',
      'Mum said: "I have finished." → Mum said that she ___ finished.|had|has|have|is',
    ]),
    Thema.liste('e8-relative', 'who, which or whose?', [
      'The boy ___ lives next door is my friend.|who|which|whose|what',
      'The book ___ I read was great.|which|who|whose|what',
      'That\'s the girl ___ dog is very loud.|whose|who|which|what',
      'I have a cat ___ loves fish.|which|who|whose|what',
      'The teacher ___ helped me is nice.|who|which|whose|what',
    ]),
  ],
};
