"""Erzeugt assets/rezepte/rezepte.json aus der Liste unten.

Zutat: (name, menge, grundzutat). Grundzutaten (Salz, Öl …) hat man meist
zu Hause – sie zählen beim „Was kann ich kochen?“ nicht als fehlend.
Aufruf: python3 tools/rezepte_bauen.py
"""
import json
from pathlib import Path

G = True  # Grundzutat

R = []
def rezept(id, name, minuten, portionen, tags, zutaten, schritte):
    R.append({"id": id, "name": name, "minuten": minuten, "portionen": portionen, "tags": tags,
              "zutaten": [{"name": z[0], "menge": z[1], "grund": len(z) > 2 and z[2]} for z in zutaten],
              "schritte": schritte})

rezept("spaghetti_aglio", "Spaghetti Aglio e Olio", 15, 2, ["vegetarisch", "schnell"],
  [("Spaghetti", "250 g"), ("Knoblauch", "3 Zehen"), ("Olivenöl", "5 EL", G), ("Chili", "1 Prise", G), ("Petersilie", "½ Bund"), ("Salz", "", G)],
  ["Spaghetti in reichlich Salzwasser bissfest kochen.", "Knoblauch in dünne Scheiben schneiden und im Olivenöl bei mittlerer Hitze goldgelb anschwitzen, Chili dazu.", "Nudeln abgießen, dabei eine Tasse Nudelwasser aufheben.", "Nudeln mit Öl, etwas Nudelwasser und gehackter Petersilie vermengen."])
rezept("eierspeis", "Eierspeis mit Brot", 10, 1, ["schnell", "frühstück"],
  [("Eier", "3"), ("Butter", "1 TL", G), ("Schnittlauch", "etwas"), ("Brot", "2 Scheiben"), ("Salz", "", G), ("Pfeffer", "", G)],
  ["Eier in einer Schüssel mit Salz und Pfeffer verquirlen.", "Butter in der Pfanne schmelzen, Eier hinein und bei kleiner Hitze langsam stocken lassen, dabei umrühren.", "Mit Schnittlauch bestreuen und mit Brot servieren."])
rezept("bratkartoffeln", "Bratkartoffeln mit Spiegelei", 30, 2, ["resteverwertung"],
  [("Kartoffeln", "600 g (gekocht)"), ("Zwiebel", "1"), ("Eier", "2"), ("Öl", "3 EL", G), ("Salz", "", G), ("Pfeffer", "", G)],
  ["Gekochte Kartoffeln in Scheiben schneiden, Zwiebel würfeln.", "Kartoffeln im Öl bei mittlerer Hitze 10–15 Minuten knusprig braten, nicht zu oft wenden.", "Zwiebel dazugeben und mitbraten, würzen.", "In einer zweiten Pfanne Spiegeleier braten und darauf servieren."])
rezept("gemuesepfanne", "Bunte Gemüsepfanne mit Reis", 30, 2, ["vegetarisch", "resteverwertung"],
  [("Reis", "150 g"), ("Paprika", "1"), ("Zucchini", "1"), ("Karotten", "2"), ("Zwiebel", "1"), ("Sojasauce", "3 EL"), ("Öl", "2 EL", G)],
  ["Reis nach Packung kochen.", "Gemüse in mundgerechte Stücke schneiden.", "Zwiebel und Karotten im Öl 3 Minuten anbraten, dann Paprika und Zucchini dazu und weitere 5 Minuten braten.", "Mit Sojasauce ablöschen und mit dem Reis servieren."])
rezept("fried_rice", "Gebratener Reis vom Vortag", 20, 2, ["resteverwertung", "schnell"],
  [("Reis", "300 g (gekocht, kalt)"), ("Eier", "2"), ("Erbsen", "100 g"), ("Frühlingszwiebeln", "2"), ("Sojasauce", "2 EL"), ("Öl", "2 EL", G)],
  ["Öl stark erhitzen, Eier hineinschlagen und unter Rühren stocken lassen, herausnehmen.", "Kalten Reis im Öl kräftig anbraten, bis er leicht knusprig wird.", "Erbsen, Frühlingszwiebeln und Ei dazu, mit Sojasauce würzen."])
rezept("tomatensuppe", "Schnelle Tomatensuppe", 20, 2, ["vegetarisch", "suppe"],
  [("Dosentomaten", "1 Dose"), ("Zwiebel", "1"), ("Knoblauch", "1 Zehe"), ("Gemüsebrühe", "300 ml"), ("Sahne", "50 ml"), ("Öl", "1 EL", G), ("Zucker", "1 Prise", G), ("Salz", "", G)],
  ["Zwiebel und Knoblauch würfeln und im Öl glasig dünsten.", "Tomaten und Brühe dazu, 10 Minuten köcheln.", "Pürieren, Sahne einrühren, mit Salz und einer Prise Zucker abschmecken."])
rezept("kaiserschmarrn", "Kaiserschmarrn", 25, 2, ["süß", "österreichisch"],
  [("Mehl", "125 g", G), ("Milch", "250 ml"), ("Eier", "3"), ("Zucker", "2 EL", G), ("Butter", "2 EL", G), ("Rosinen", "1 Handvoll"), ("Staubzucker", "zum Bestreuen")],
  ["Eier trennen. Eigelb mit Mehl, Milch und Zucker glatt rühren.", "Eiweiß steif schlagen und unterheben.", "Butter in einer großen Pfanne schmelzen, Teig hineingießen, Rosinen darüber, bei mittlerer Hitze stocken lassen.", "Wenden, mit zwei Gabeln in Stücke reißen und kurz weiterbraten.", "Mit Staubzucker bestreuen. Dazu passt Apfelmus."])
rezept("palatschinken", "Palatschinken", 25, 2, ["süß", "österreichisch"],
  [("Mehl", "150 g", G), ("Milch", "300 ml"), ("Eier", "2"), ("Butter", "zum Ausbacken", G), ("Marmelade", "nach Belieben"), ("Salz", "1 Prise", G)],
  ["Mehl, Milch, Eier und Salz zu einem glatten Teig rühren, 10 Minuten rasten lassen.", "In wenig Butter dünne Palatschinken ausbacken.", "Mit Marmelade bestreichen und einrollen."])
rezept("nudelauflauf", "Nudelauflauf mit Schinken", 45, 3, ["ofen", "resteverwertung"],
  [("Nudeln", "300 g"), ("Schinken", "150 g"), ("Eier", "2"), ("Sahne", "200 ml"), ("Käse", "100 g (gerieben)"), ("Salz", "", G), ("Pfeffer", "", G)],
  ["Ofen auf 200 °C vorheizen. Nudeln kochen.", "Schinken würfeln, mit Nudeln in eine Auflaufform geben.", "Eier mit Sahne, Salz und Pfeffer verquirlen und darübergießen.", "Mit Käse bestreuen und 20–25 Minuten goldbraun backen."])
rezept("chili", "Chili sin Carne", 40, 3, ["vegetarisch", "eintopf"],
  [("Kidneybohnen", "1 Dose"), ("Mais", "1 Dose"), ("Dosentomaten", "1 Dose"), ("Paprika", "1"), ("Zwiebel", "1"), ("Knoblauch", "2 Zehen"), ("Paprikapulver", "1 TL", G), ("Kreuzkümmel", "1 TL", G), ("Öl", "2 EL", G)],
  ["Zwiebel, Knoblauch und Paprika würfeln und im Öl anbraten.", "Gewürze kurz mitrösten.", "Tomaten, abgespülte Bohnen und Mais dazu und 20 Minuten köcheln.", "Abschmecken. Dazu Reis oder Brot."])
rezept("linsencurry", "Rotes Linsencurry", 30, 3, ["vegan", "eintopf"],
  [("Rote Linsen", "200 g"), ("Kokosmilch", "1 Dose"), ("Dosentomaten", "1 Dose"), ("Zwiebel", "1"), ("Knoblauch", "2 Zehen"), ("Ingwer", "1 Stück"), ("Currypulver", "2 TL", G), ("Öl", "1 EL", G)],
  ["Zwiebel, Knoblauch und Ingwer fein hacken und im Öl anschwitzen, Curry kurz mitrösten.", "Linsen, Tomaten, Kokosmilch und 200 ml Wasser dazu.", "15–20 Minuten köcheln, bis die Linsen weich sind. Mit Salz abschmecken."])
rezept("pfannkuchen_herzhaft", "Herzhafte Pfannkuchen mit Käse", 25, 2, ["vegetarisch"],
  [("Mehl", "150 g", G), ("Milch", "250 ml"), ("Eier", "2"), ("Käse", "100 g"), ("Spinat", "100 g"), ("Butter", "zum Braten", G), ("Salz", "", G)],
  ["Teig aus Mehl, Milch, Eiern und Salz rühren.", "Pfannkuchen ausbacken, auf einer Hälfte Spinat und Käse verteilen.", "Zuklappen und kurz weiterbraten, bis der Käse schmilzt."])
rezept("kartoffelsuppe", "Kartoffelsuppe", 35, 3, ["suppe", "vegetarisch"],
  [("Kartoffeln", "600 g"), ("Karotten", "2"), ("Lauch", "1 Stange"), ("Gemüsebrühe", "1 l"), ("Sahne", "100 ml"), ("Majoran", "1 TL", G), ("Butter", "1 EL", G)],
  ["Gemüse schälen und klein schneiden.", "In Butter anschwitzen, mit Brühe aufgießen und 20 Minuten kochen.", "Teilweise pürieren, Sahne dazu, mit Majoran, Salz und Pfeffer abschmecken."])
rezept("gulasch_wuerstel", "Würstelgulasch", 35, 3, ["österreichisch", "eintopf"],
  [("Würstel", "4"), ("Kartoffeln", "500 g"), ("Zwiebel", "2"), ("Paprikapulver", "2 EL", G), ("Tomatenmark", "1 EL"), ("Öl", "2 EL", G), ("Salz", "", G)],
  ["Zwiebeln würfeln und im Öl goldbraun rösten.", "Paprikapulver und Tomatenmark kurz mitrösten, mit 600 ml Wasser aufgießen.", "Kartoffelwürfel dazu und 20 Minuten köcheln.", "Würstel in Scheiben dazu und 5 Minuten mitziehen lassen."])
rezept("toast_hawaii", "Toast Hawaii", 15, 2, ["ofen", "schnell"],
  [("Toastbrot", "4 Scheiben"), ("Schinken", "4 Scheiben"), ("Ananas", "4 Scheiben"), ("Käse", "4 Scheiben"), ("Butter", "etwas", G)],
  ["Ofen auf 220 °C vorheizen.", "Toast buttern, mit Schinken, Ananas und Käse belegen.", "8–10 Minuten überbacken."])
rezept("griechischer_salat", "Griechischer Salat", 15, 2, ["vegetarisch", "salat", "schnell"],
  [("Gurke", "1"), ("Tomaten", "3"), ("Paprika", "1"), ("Zwiebel", "1"), ("Feta", "150 g"), ("Oliven", "1 Handvoll"), ("Olivenöl", "3 EL", G), ("Essig", "1 EL", G)],
  ["Gemüse in Stücke schneiden, Zwiebel in Ringe.", "Mit Oliven mischen, Feta darauf bröseln.", "Mit Öl, Essig, Salz und Oregano anmachen."])
rezept("couscous_salat", "Couscous-Salat", 20, 3, ["vegan", "salat"],
  [("Couscous", "200 g"), ("Gurke", "1"), ("Tomaten", "2"), ("Paprika", "1"), ("Zitrone", "1"), ("Petersilie", "1 Bund"), ("Olivenöl", "4 EL", G)],
  ["Couscous mit 250 ml heißem Salzwasser übergießen, 5 Minuten quellen lassen, auflockern.", "Gemüse klein würfeln, Petersilie hacken.", "Alles mischen, mit Zitronensaft, Öl, Salz und Pfeffer abschmecken."])
rezept("wraps", "Wraps mit Hähnchen", 25, 2, ["schnell"],
  [("Tortillas", "4"), ("Hähnchen", "250 g"), ("Salat", "½ Kopf"), ("Tomaten", "2"), ("Joghurt", "150 g"), ("Paprikapulver", "1 TL", G), ("Öl", "1 EL", G)],
  ["Hähnchen in Streifen schneiden, mit Paprika und Salz würzen und im Öl durchbraten.", "Joghurt mit Salz, Pfeffer und etwas Knoblauch verrühren.", "Tortillas kurz erwärmen, mit Sauce, Salat, Tomaten und Hähnchen füllen und einrollen."])
rezept("omelett", "Gemüse-Omelett", 15, 1, ["vegetarisch", "schnell", "resteverwertung"],
  [("Eier", "3"), ("Paprika", "½"), ("Champignons", "4"), ("Käse", "30 g"), ("Butter", "1 TL", G), ("Salz", "", G)],
  ["Gemüse klein schneiden und in Butter anbraten.", "Verquirlte, gesalzene Eier darübergießen und bei kleiner Hitze stocken lassen.", "Käse darauf, zusammenklappen."])
rezept("bananenbrot", "Bananenbrot", 70, 8, ["süß", "ofen", "resteverwertung"],
  [("Bananen", "3 (sehr reif)"), ("Mehl", "250 g", G), ("Zucker", "100 g", G), ("Eier", "2"), ("Butter", "80 g", G), ("Backpulver", "1 Pkg."), ("Nüsse", "1 Handvoll")],
  ["Ofen auf 180 °C vorheizen, Kastenform einfetten.", "Bananen zerdrücken, mit geschmolzener Butter, Zucker und Eiern verrühren.", "Mehl und Backpulver unterheben, Nüsse dazu.", "Etwa 55 Minuten backen (Stäbchenprobe)."])
rezept("pizza_toast", "Pizzatoast", 15, 2, ["ofen", "schnell", "resteverwertung"],
  [("Toastbrot", "4 Scheiben"), ("Tomatenmark", "2 EL"), ("Käse", "100 g"), ("Salami", "8 Scheiben"), ("Oregano", "1 TL", G)],
  ["Ofen auf 220 °C vorheizen.", "Toast mit Tomatenmark bestreichen, mit Oregano würzen.", "Mit Salami und Käse belegen und 8 Minuten backen."])
rezept("milchreis", "Milchreis mit Zimt", 35, 3, ["süß"],
  [("Milchreis", "200 g"), ("Milch", "1 l"), ("Zucker", "3 EL", G), ("Zimt", "1 TL", G), ("Butter", "1 EL", G)],
  ["Milch mit Butter und Zucker aufkochen.", "Reis einrühren und bei kleinster Hitze 30 Minuten quellen lassen, öfter umrühren.", "Mit Zimt und Zucker bestreut servieren."])
rezept("pesto_nudeln", "Nudeln mit Pesto und Tomaten", 15, 2, ["vegetarisch", "schnell"],
  [("Nudeln", "250 g"), ("Pesto", "4 EL"), ("Cocktailtomaten", "200 g"), ("Parmesan", "30 g")],
  ["Nudeln kochen.", "Tomaten halbieren.", "Nudeln abgießen, mit Pesto und Tomaten mischen, Parmesan darüber."])
rezept("shakshuka", "Shakshuka", 30, 2, ["vegetarisch"],
  [("Eier", "4"), ("Dosentomaten", "1 Dose"), ("Paprika", "1"), ("Zwiebel", "1"), ("Knoblauch", "2 Zehen"), ("Kreuzkümmel", "1 TL", G), ("Paprikapulver", "1 TL", G), ("Öl", "2 EL", G), ("Brot", "zum Tunken")],
  ["Zwiebel, Paprika und Knoblauch im Öl weich dünsten, Gewürze dazu.", "Tomaten dazu und 10 Minuten einkochen.", "Vier Mulden machen, Eier hineinschlagen und zugedeckt 6–8 Minuten stocken lassen.", "Mit Brot servieren."])
rezept("ofengemuese", "Ofengemüse mit Feta", 45, 2, ["vegetarisch", "ofen", "resteverwertung"],
  [("Kartoffeln", "400 g"), ("Karotten", "2"), ("Zucchini", "1"), ("Paprika", "1"), ("Feta", "150 g"), ("Olivenöl", "4 EL", G), ("Rosmarin", "1 Zweig", G)],
  ["Ofen auf 200 °C vorheizen.", "Gemüse in Stücke schneiden, mit Öl, Salz und Rosmarin mischen.", "Auf dem Blech 30 Minuten rösten.", "Feta darüberbröseln und 10 Minuten weiterbacken."])
rezept("frittata", "Nudel-Frittata (aus Resten)", 20, 2, ["resteverwertung"],
  [("Nudeln", "250 g (gekocht)"), ("Eier", "4"), ("Käse", "60 g"), ("Schinken", "80 g"), ("Butter", "1 EL", G), ("Salz", "", G)],
  ["Eier mit Käse, Salz und Pfeffer verquirlen, Schinken würfeln.", "Nudeln und Schinken in Butter anbraten, Eiermasse darübergießen.", "Zugedeckt bei kleiner Hitze 10 Minuten stocken lassen, dann wenden oder kurz unter den Grill."])
rezept("bohnensalat", "Bohnensalat mit Ei", 15, 2, ["salat", "schnell"],
  [("Kidneybohnen", "1 Dose"), ("Eier", "2"), ("Zwiebel", "1 (rot)"), ("Essig", "2 EL", G), ("Öl", "3 EL", G), ("Salz", "", G)],
  ["Eier hart kochen und vierteln.", "Bohnen abspülen, Zwiebel fein schneiden.", "Mit Essig, Öl, Salz und Pfeffer anmachen, Eier darauf."])
rezept("apfelstrudel_blaetterteig", "Schneller Apfelstrudel", 45, 6, ["süß", "ofen", "österreichisch"],
  [("Blätterteig", "1 Rolle"), ("Äpfel", "4"), ("Zucker", "3 EL", G), ("Zimt", "1 TL", G), ("Rosinen", "1 Handvoll"), ("Semmelbrösel", "2 EL"), ("Eier", "1")],
  ["Ofen auf 200 °C vorheizen.", "Äpfel schälen, in dünne Scheiben schneiden, mit Zucker, Zimt und Rosinen mischen.", "Blätterteig ausrollen, mit Bröseln bestreuen, Äpfel darauf verteilen und einrollen.", "Mit verquirltem Ei bestreichen und 30 Minuten backen."])
rezept("gefuellte_paprika", "Gefüllte Paprika", 60, 3, ["ofen"],
  [("Paprika", "4"), ("Faschiertes", "300 g"), ("Reis", "80 g"), ("Zwiebel", "1"), ("Dosentomaten", "1 Dose"), ("Paprikapulver", "1 TL", G), ("Salz", "", G)],
  ["Reis halb gar kochen. Ofen auf 180 °C vorheizen.", "Faschiertes mit Reis, gehackter Zwiebel, Salz und Paprikapulver vermengen.", "Paprika aushöhlen, füllen und in eine Form mit den Tomaten setzen.", "Zugedeckt 40 Minuten backen."])
rezept("overnight_oats", "Overnight Oats", 5, 1, ["frühstück", "schnell"],
  [("Haferflocken", "50 g"), ("Milch", "150 ml"), ("Joghurt", "2 EL"), ("Honig", "1 TL", G), ("Obst", "1 Handvoll")],
  ["Haferflocken mit Milch, Joghurt und Honig in einem Glas verrühren.", "Über Nacht in den Kühlschrank stellen.", "Morgens mit Obst essen."])
rezept("gemuesecremesuppe", "Gemüsecremesuppe aus Resten", 30, 3, ["suppe", "vegetarisch", "resteverwertung"],
  [("Karotten", "3"), ("Kartoffeln", "2"), ("Zucchini", "1"), ("Zwiebel", "1"), ("Gemüsebrühe", "800 ml"), ("Sahne", "100 ml"), ("Butter", "1 EL", G)],
  ["Zwiebel in Butter anschwitzen, restliches Gemüse klein geschnitten dazu.", "Mit Brühe aufgießen und 20 Minuten weich kochen.", "Pürieren, Sahne einrühren und abschmecken."])

ziel = Path(__file__).resolve().parent.parent / "assets" / "rezepte" / "rezepte.json"
json.dump(R, open(ziel, "w"), ensure_ascii=False, indent=1)
print(len(R), "Rezepte →", ziel)
