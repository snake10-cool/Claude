"""Erzeugt die Wortlisten für das Worträtsel.

- assets/woerter/loesungen.txt: eigene Liste häufiger Wörter (siehe unten)
- assets/woerter/erlaubt.txt:   erlaubte Rateversuche, aus wordfreq
  (Robyn Speer, Daten unter CC BY-SA 4.0, https://github.com/rspeer/wordfreq)

Aufruf (einmalig): pip install wordfreq && python3 tools/woerter_bauen.py
"""
import random
import re
from pathlib import Path

from wordfreq import top_n_list

ZIEL = Path(__file__).resolve().parent.parent / "assets" / "woerter"

# Lösungswörter: häufig, alltagstauglich, ohne Eigennamen und Schimpfwörter.
LOESUNGEN = """
abend achse adler affen alarm alpen ampel angel angst anker apfel april arena armee asche atlas atmen augen autos
bäche backe bagel bahre ballon? balle bande banjo baron bauch bauer baume beere beine beruf besen beton bibel biber biene bilde birne bisse blase blatt blech blick blitz block blume boden bogen bohne boote börse brand braun brett brief brise brote brust buche bücher? bühne bulle bunte burgs?
chaos chips chlor clown couch creme
dachs dampf decke deich delle denke diebe dinge docht dosen draht drama dreck drohe duell dunst durst düsen
ebene echse edeln efeus eiche eigen eimer eisen elche elfen engel enkel ernte esche essig etage eulen extra
fabel faden fähre falke falle farbe fass? fasse feder fehde feier feige feile felge felle ferne fertig? ferse feste fette fichte? figur filme finne firma fisch flach flamme? flash? flegs? fleck flieg? flora fluss? flügel? flöte folge forme forst foto? frack frage frost frust fuchs fugen funke furche? futter?
gabel gabe? gänse garbe garne gasse gäste gatte geist geier gelde gelee genie gerte geste gicht gipfel? gipsy? glanz glase glatt glück? gnade golfs? gramm grand? grass? greif grill grips große? grube grund gruss? gummi gurke gürtel? güter
haare hafen hafer hagel haken halde halle halme hälse handy hanfs? harfe harke harte hasen haube haufe hause? hebel hecke heere hefte helme hemde herde herzs? hexen hilfe himmel? hirse hitze hobel hobby hoden? hofes höhle honig hosen hotel hügel hunde hüpfe? hütte
idole igels imker inder? insel irren
jacke jäger jahre jeans joker juwel
kabel käfer kaffe? kahle kakao kalbs? kälte kamel kamin kampf kanal kante kappe karte kasse katze kegel kehle keile keime kekse kelch kelle kerbe kerze kette keule kiefer? kiste kiwis klage klang klapp? klaue klebe kleid klima klinke? kluft knall knete knopf koala kocht? kohle kojen kolle? komet konto kopfe? kopie korbs? kraft kranz kraut krebs kreis kreuz krieg krone krume? kröte krümel? kuche? kufen kugel kühle kunst kurve küste
lachs laden lager lampe lande? lange lanze lasso laube lauch laune leben leder leere lehre leine lende lerne? leser leute licht liebe lieder? liege lilie limit linde linie linse liste liter lobby locke löffel? lotse löwen lücke luchs lüfte? lunge
macht mädel? magen mähne malen mango manko markt maske maßes? masse mauer maus? meere mehls? meile meise menge menue? metall? miete milch minze mixer mobil modem mönch monat moped moral morgen? motor möwen mühle mulde münze musik muster? mütze
nabel nacht nadel nagel naher? namen narbe narre? nebel neffe nerven? nest? netze nicke? niere nonne notiz nudel nüsse
oasen obere? oboen ofens? ohren oktav? onkel opern orden orgel ozean
paare paket palme panda panne papst parks paste pause pedal pegel perle pfahl pfand pfeil pferd pflug pfote piano pilot pilze pinie pinne pirat pixel pizza plage plane platz pokal polar polen? polle? porto posse? prinz probe profi puder pulli pulse? puppe putze?
quark quarz quote
rabbi? rache radar raben rahme? rampe rande? rasen rasse ratte raupe reben regal regel regen reich reife reihe reise reiter? rente reste rhein? riese rinde ringe rippe ritze robbe roboter? rocke? rolle roman rosen rosse? rotor rübe? rubin rücke? rufen rugby ruhig? ruine rumba runde rüsse?
saale? säbel sache sacke? sahne saite salat salbe salon salze samen sande? satte? sauna schaf? schal schar? schaum? schaf? schuh? seele segel sehne seide seife seile seite sekte? senfs? serie sessel? sicht sieger? silbe simse? sinne sirup sitte skala skier socke sofas sonne sorge sorte sosse? spalt spatz speck speer spiel spitz sporn sport spott sprit spuke? spule spurt staat stadt stahl stall stamm stand stapel? stars? staub steak steig stein stelle? stern stich stiel stier stift stirn stock stoff stolz storch? strom stube stuck stufe stuhl stumm sturm sucht süden summe sumpf suppe szene
tabak tafel taler tango tanne tante tanze? tapir tasche? taste tatze taube tauen teich teile teint tempo tenor terme? tests texte thron tiger tinte tisch titel toast tobak? tonne torte trabi? trage trank traum treue trick trieb tritt trost truhe tuben tulpe tumor turme? tusche?
übung ufers? ulmen umzug? unfug unter? urahn? urlaub?
vasen vater venen verse video vieh? villa vögel volks? vorne?
waage waben wache waffe wagen wahle? waise walde? walze wange wanne wanze waren? watte weber wecke? weide weise weite welle welpe welte? wende werft werke werte wespe weste wette wicht wiege wiese wille winde? wirbel? wirte? wisch? witze woche wolfs? wolke wolle wonne worte wüste wurfe? würze wurst
yacht
zange zaube? zebra zecke zehen zeile zeit? zelte zelle? ziege zielt? ziffer? zinke zinne zirkus? zitat zitrus? zocke? zonen zopfe? zucht zucker? zunge zweig zwerg
"""


# Beim Durchsehen aussortiert (gebeugte oder unnatürliche Formen).
AUSSORTIERT = set("""
balle baume bilde bisse denke drohe edeln efeus fasse forme garne gelde glase
harte haufe hefte hemde hofes igels kahle klebe kojen pinne salze tests bunte fette
""".split())


def main():
    erlaubt = {
        w for w in top_n_list("de", 200000)
        if len(w) == 5 and re.fullmatch(r"[a-zäöü]{5}", w)
    }
    loesungen = []
    for w in LOESUNGEN.split():
        if w.endswith("?"):
            continue  # unsicher/zu lang → weglassen
        if len(w) != 5 or not re.fullmatch(r"[a-zäöü]{5}", w) or w in AUSSORTIERT:
            continue
        loesungen.append(w)
    loesungen = sorted(set(loesungen))
    erlaubt |= set(loesungen)
    # Feste, nicht alphabetische Reihenfolge für die Tagesrätsel.
    random.Random(2026).shuffle(loesungen)
    ZIEL.mkdir(parents=True, exist_ok=True)
    (ZIEL / "loesungen.txt").write_text("\n".join(loesungen) + "\n")
    (ZIEL / "erlaubt.txt").write_text("\n".join(sorted(erlaubt)) + "\n")
    print(len(loesungen), "Lösungen,", len(erlaubt), "erlaubte Wörter")


if __name__ == "__main__":
    main()
