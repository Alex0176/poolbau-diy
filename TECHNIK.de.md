# Parametrischer Edelstahlpool – Entwicklungsstand

[GitHub-README Deutsch](README.md) · [GitHub-README English](README.en.md)

Geplanter Werkstoff ist **Duplex-Edelstahl 1.4462 (2205)**, geplanter Fertigungsweg Laserschweißen. Werkstoff- und Verfahrenseignung müssen für die tatsächliche Ausführung geprüft werden. Es wird keine Immunität gegen Flugrost zugesichert; fachliche Einordnung und Quellen stehen in beiden README-Dateien.

Aus einer vorhandenen OpenSCAD-Vorlage abgeleiteter, lokal ausführbarer Pool-Konfigurator. Alle Maße in **mm**. Benötigt OpenSCAD (getestet mit der lokal installierten Version) und für den Sammel-Export Python 3.10 oder neuer, ohne zusätzliche Python-Pakete.

## Schnellstart

1. `pool_parametrisch.scad` in OpenSCAD öffnen.
2. Parameter oben im Quelltext ändern und speichern; alternativ den OpenSCAD-Customizer verwenden.
3. F5 für die farbige Ansicht. **Die lesbare Stückliste steht in der OpenSCAD-Konsole; ein Montageplan steht standardmäßig neben dem Modell.** `ansicht="Fertigungsplan"` zeigt ihn allein. `fertigungsplan_zeigen=false` blendet die seitliche Tafel aus. `Stuetzendetail` zeigt ein einzelnes räumliches K-Stützenpaar, `Profilkontur` die Seitenkontur einer Diagonale. `teil_index` entspricht der Blechliste, `fliese_index` der Fliesenliste und `profil_index` der Reihenfolge in `profile_geometrie.json`. Für einen freien Blick in die Rinne `fliesen_zeigen=false` setzen.
4. Im Projektordner `python export.py` ausführen. Die Werte werden direkt aus der gespeicherten SCAD-Datei gelesen. **Nur im Customizer veränderte, nicht im Quelltext gespeicherte Werte übernimmt dieser Aufruf nicht.** Alternativ Werte per `-D` übergeben.
5. `export-stueckliste-v4/stueckliste.html` für Stückliste und Montageplan öffnen; `schnittzeichnungen.html` enthält die Einzelteilzeichnungen. DXF ist maßhaltig in mm; SVG/HTML sind bemaßte Ansichten, keine Papier-Schablonen. Ältere Exportordner bleiben als frühere Stände erhalten.

## Stückliste und Montageplan – Version 4

`materialliste=true` gibt bei F5/F6 lesbare Mengen und Maße in der Konsole aus. Gleiche Profilquerschnitte und Längen sind zusammengefasst. Alle Blechzuschnitte folgen einzeln mit ID, Stückzahl und Länge/Breite/Dicke. `export_daten=false` unterdrückt die internen Geometriedatensätze; das Exportskript schaltet sie automatisch hinzu.

Die seitliche Tafel zeigt das K-Stützenpaar in Seitenansicht, **die Anzahl und Längen je Paar**, die gesamte Profilstückliste sowie markierte Verbindungsstellen: J1 am inneren K-Knoten, J2/J3 an den äußeren Strebenanschlüssen, J4 an oberen/unteren Rahmenanschlüssen. Die Markierungen beschreiben die Montageanordnung, **keine bemessenen Schweißnahtsymbole**. Nahtdicke, Nahtlänge, Nahtart und Schweißfolge sind noch festzulegen.

Die Längen für U-Ständer und Rechteckrohre sind Nennzuschnittlängen. Bei UD-Diagonalen ist die angegebene Rohprofillänge die maximale Länge vor dem schrägen Endbeschnitt; die exakten Konturen bleiben in den KD-Zeichnungen. Sägefuge, Besäumung, Schweißzugaben und Lieferlängen sind nicht eingerechnet. Die Gesamtmeter sind deshalb **Materialbedarf und keine Bestellanzahl von 6-m-Stangen**. Die aktuellen langen Rahmenstücke sind über 6 m lang; passende Lieferlängen müssen angefragt werden, es wird keine unbemessene Stoßverbindung angenommen.

Neue Dateien: `profilstueckliste_gruppiert.csv`, `stueckliste.txt`, `stueckliste.html` und `montageplan.svg`. Die Zeichnungsmappe verlinkt diese Übersicht. Ein erneuter Export berechnet alles aus den aktuellen SCAD-Parametern. `--reuse-geometry` ist nur zur Wiederverwendung bereits vorhandener Zeichnungen gedacht und wird abgewiesen, wenn die gespeicherten Geometriedatensätze abweichen.

**Dein Entwurf ist ein Überlaufpool.** `skimmer_aktiv=false` ist die Voreinstellung. Nur wenn andere Nutzer `skimmer_aktiv=true` setzen, entsteht die Skimmervariante: ohne Überlaufrinne, Fliesen, Rinnenauflager und Anschläge. Modell und Stückliste folgen demselben Schalter; beide Systeme werden nicht gleichzeitig eingebaut.

Beispiel mit anderem Ausschnitt und 3-mm-Blech:

```powershell
python export.py --out export-4000 -D ausschnitt_breite=4000 -D ausschnitt_laenge=9000 -D blech=3
```

Andere OpenSCAD-Installation: `python export.py --openscad "C:\Program Files\OpenSCAD\openscad.com"`. Exportziele werden bei erneutem Aufruf überschrieben; für Varianten eigene Ausgabeordner verwenden. Bei verringerter Teilezahl können alte Dateien im wiederverwendeten Ordner verbleiben; maßgeblich sind die aktuellen CSV-Listen und das aktuelle HTML.

## Maße und automatische Ableitungen

Der vorhandene Ausschnitt ist **3150 × 7500**, nicht das lichte Innenmaß. Die obere Rinne darf diesen Ausschnitt überragen. Die vorläufigen Eingaben `tragwerk_platz=150` und `montageluft=10` gelten **je Seite**. Damit ergibt sich zunächst ein Innenmaß von **2830 × 7180 mm**, bei 1500 mm Wandhöhe. Das ist eine transparente Platzannahme, kein statisch bestimmter Platzbedarf. Das Tragwerk ist noch in Entwicklung.

`breite = ausschnitt_breite - 2*(tragwerk_platz + montageluft)`, entsprechend für die Länge. Die Höhe bezieht sich auf den Boden an der Außenwand. Zur Mittelrinne fällt der Boden ab; dort ist das Becken tiefer. Bezugssystem: X quer, Y längs, Z oben; Boden-Wand-Anschluss bei Z=0, Beckenoberkante bei Z=hoehe.

| Parameter | Wirkung |
|---|---|
| `ausschnitt_breite`, `ausschnitt_laenge`, `hoehe` | Raum und Beckenhöhe |
| `tragwerk_platz`, `montageluft` | Platzreserve und Montageabstand |
| `blech`, `werkstoff` | Blechstärke und Materialtext; 2/3 mm möglich |
| `tafel_lang`, `tafel_kurz` | Großformat, voreingestellt 3000 × 1500 |
| `gefaelle_prozent` | Neigung beider Bodenhälften zur Längsrinne |
| `rinnenbreite`, `rinnentiefe` | Mittige offene Sammelrinne |
| `ablauf_positionen` | Relative Anschlusspositionen, 0…1 entlang Y |
| `skimmer_aktiv` | Standard `false`: Überlaufpool; `true`: Skimmer statt Überlaufrinne |
| `skimmer_position`, `skimmer_groesse` | Relative Position und reale Öffnungsgröße |
| `ueberlauf_tiefe` | Rinnentiefe unter dem inneren Auflager |
| `fliesen_breite`, `fliesen_laenge` | Tatsächliches Fliesenformat, zunächst 200 × 200 mm |
| `fliesen_gefaelle_prozent` | Gefälle zum Pool, zunächst 2 % als Geometrieannahme |
| `fliesen_fuge`, `fliesen_dicke`, `fliesen_randspiel` | Fugen, Fliesenstärke und seitliche Montagefreiheit |
| `auflager_breite`, `anschlag_hoehe` | Durchgehende Auflagerstreifen und innerer Anschlag |
| `gegenstrom`, `gegenstrom_position` | Gegenstromöffnung vorn; relative Position |
| `duesen_automatisch`, `duesen_max_abstand` | Automatische Anzahl und gleichmäßige Positionierung |
| `duesen_manuell` | Alternativ individuelle Positionen und Ziel-Y in mm |
| `stuetzen_max_abstand`, `u_breite`, `u_tiefe`, `profil_dicke` | Umlaufende U-Stützen als geometrische Vorlage |
| `rahmen_breite`, `rahmen_tiefe` | Obere und untere Rechteckrohr-Rahmen |
| `stuetzen_bautiefe` | Gesamttiefe eines gegengleichen U-Stützenpaares |
| `stuetzen_verband` | `K` mit zwei Diagonalstücken, alternativ `Einzeldiagonale` |
| `diagonal_endlage`, `diagonal_spiel` | Anschlusshöhen und seitliches Einpassspiel der Diagonalen |

Relative Anschlusspositionen bleiben beim Ändern der Beckengröße proportional erhalten. Herstellermaße von Einbauteilen bleiben reale Millimetermaße. Kleine Becken oder unpassende Öffnungen werden durch Plausibilitätsprüfungen zurückgewiesen. Weitere Kollisionsprüfungen sind noch erforderlich.

## Gegengleiche U-Stützen und K-Verband – Version 3

Die Einzelständer aus Version 1/2 haben das vom Autor vorgesehene Aussteifungsprinzip nicht wiedergegeben. Wieder enthalten ist jetzt je Station ein **inneres und ein äußeres U-Profil mit einander zugewandten offenen Seiten**, verbunden durch den K-Verband. Zwei schräge U-Stücke führen vom mittleren Knoten des inneren Profils zu oberen und unteren Anschlusspunkten am äußeren Profil. Alternativ ist eine einzelne durchgehende Diagonale auswählbar; diese Option ist kein Nachweis gleichwertiger Tragfähigkeit.

Die Standardeinstellung bildet die K-Form aus der ursprünglichen Datei ab. Stützenabstand, Bautiefe, Querschnitte und Anschlusshöhen sind Parameter. Die Bautiefe beträgt vorläufig 140 mm innerhalb der bisher angenommenen 150-mm-Tragwerkreserve. **Diese Bautiefe ist keine bestätigte Herstellerabmessung.** Soll die ursprüngliche, größere Stützentiefe übernommen werden, müssen `stuetzen_bautiefe` und `tragwerk_platz` gemeinsam angepasst werden; damit ändern sich die lichten Beckenmaße.

Die senkrechten U-Profile sind voreingestellt 80 × 40 × 2 mm. Die diagonalen Profile werden geometrisch auf `80 - 2*2 - 2*1 = 74 mm` Breite reduziert, damit sie mit 1 mm seitlichem Spiel in die offenen U-Profile passen. Das ist ein **benötigter Querschnitt, keine Zusage eines handelsüblichen Kaufprofils**. Reale Profilradien, Toleranzen und gegebenenfalls Kantprofile sind bei der Detailplanung zu berücksichtigen.

Die Diagonalen enden an den inneren Stegflächen der senkrechten Profile; am mittleren K-Knoten werden ihre Konturen zusätzlich horizontal zugeschnitten, damit die beiden Strebenkörper sich nicht überlagern. Deshalb erhalten sie **schräge Enden**, keine pauschalen rechtwinkligen Zuschnitte. `KD*.dxf` und die zugehörigen Maßblätter zeigen die seitliche Hüllkontur des fertigen U-Profilstücks. Es handelt sich **nicht um flache Blechabwicklungen**. Die maximale benötigte Rohprofillänge, das Achsmaß und der Winkel der Endebene gegenüber einem rechtwinkligen Schnitt stehen in `profile.csv`. Schweißspalte/Zugaben sind noch nicht fertigungsseitig festgelegt.

Obere und untere gerade Querbinder verbinden den äußeren Ständer mit dem umlaufenden inneren Rahmen. Der flache Rinnenboden liegt weiterhin über dem Rahmen und den oberen Querbindern, sodass keine Stützenausschnitte erforderlich sind. Die Wandzone oberhalb dieses Rahmens sowie alle Verbindungen sind Teil der noch offenen statischen Bemessung. Ein Rinnenablauf, der mit einem Querbinder kollidieren würde, wird automatisch in die benachbarte Feldmitte verschoben; gewünschte und tatsächliche Position stehen als `OUTLET` im Exportprotokoll.

## Rinne mit geneigten Fliesen

Die Fliesen liegen mit ihrer Unterseite auf zwei durchgehenden, passend geneigten Edelstahlstreifen, zunächst je **25 mm breit**. Der äußere Streifen liegt höher. Poolseitig begrenzt ein **8 mm hoher Anschlag** das Verrutschen; er bleibt unter der Fliesenoberkante. Seitlich bleiben zunächst 2 mm Spiel. Die **20 mm Fliesenstärke ist ein veränderbarer Platzhalter** und muss zum tatsächlich verwendeten Produkt passen.

Aus der echten 200-mm-Fliesenbreite wird ihre horizontale Projektion berechnet: `200*cos(atan(2/100))`. Hinzu kommen Anschlagdicke und Randspiel. So ergeben sich **205,96 mm lichte Rinnenbreite** und **4,12 mm Erhöhung** an der Außenwand. Über die Fliese selbst beträgt der Höhenunterschied knapp 4 mm. Die Außenwand, beide Auflager und jede einzelne Fliese folgen derselben Neigung. `ueberlauf_breite` ist jetzt ein abgeleiteter Wert; zum Ändern der Rinnenbreite das Fliesenformat ändern.

Der obere Rechteckrohrrahmen endet genau unter dem flachen Rinnenboden. Die U-Stützen enden wiederum unter diesem Rahmen. Dadurch läuft das Rinnenblech als gerades „Dach“ über die Stützen, ohne Stützenausschnitte. Bei den Standardwerten liegt die Rahmenoberkante bei Z=1298 mm, die Rinnenboden-Oberseite bei Z=1300 mm und das innere Fliesenauflager bei Z=1500 mm. Die Stützenlänge wird automatisch angepasst. Die Rinnenabläufe liegen außerhalb des Randrahmens; unzureichender seitlicher Platz wird zurückgewiesen.

Die Fliesen bleiben entlang gerader Strecken im echten 200-mm-Format, mit 8-mm-Fugen und zugeschnittenen Reststücken. An den vier Ecken treffen die geneigten Flächen auf einer Gehrung mit offener Fuge zusammen. **Eck- und Restzuschnitte bleiben erforderlich**, aber keine Ausschnitte um Stützen. Auch die Auflager und Rinnenböden erhalten Eckgehrungen, die im DXF enthalten sind. Die Randauflager bedecken nur die Randbereiche; der mittlere Rinnenquerschnitt bleibt unter den Fugen offen. Eine ausreichende Entwässerungsleistung ist damit noch nicht nachgewiesen.

`ansicht="Rinnendetail"` zeigt einen echten Modellquerschnitt mit Fliese, Anschlag, Auflagern, Rinne und Rahmen. Poolseite ist rechts. Der Export enthält diesen Querschnitt als SVG/DXF und am Anfang der Zeichnungsmappe. Diese Änderung beschreibt die Geometrie der Auflager; sie ersetzt keine Bemessung der Fliesen, Auflagerbleche oder Schweißanschlüsse.

## Großformat und Fertigungsdaten

Die Funktionen nutzen volle Tafellängen, danach Reststücke. Die zweite Richtung wird ebenfalls auf das Tafelformat begrenzt. Stirnwände erhalten zuerst die oberen vollen Plattenhöhen und anschließend die unteren Profilstücke. Der Boden wird über seine **schräge reale Länge** abgewickelt. Das ist keine verschachtelte Materialoptimierung: schmale Rinnenstreifen könnten gemeinsam auf einer Tafel liegen, aber eine optimale Nesting-Lösung bzw. eine Bestellmenge ganzer Tafeln wird nicht behauptet.

Jedes Blech besitzt genau einen Datensatz mit Kontur, Öffnungen, Montageursprung, lokalen Achsen und Dickenrichtung. Daraus entstehen 3D-Modell, Materialliste und DXF. Keine gebogenen Bleche: Die Rinnen bestehen aus getrennten, zu verschweißenden Blechen. Außenmaße der U-Kaufprofile sind **keine** Blechabwicklung; Biegeradius und K-Faktor sind nicht modelliert.

Der Export erstellt:

- `materialliste.csv`: ein Datensatz je Blech, Abmessungen, Dicke, Werkstoff, Rohrechteckfläche (keine Nettofläche, keine Masse).
- `profile.csv`: innere/äußere U-Stützen (`KI`/`KA`), Diagonalen (`KD`), Querbinder (`KT`) und Randrahmen mit Längen, Querschnitten, Positionen und Schnittwinkeln. Zusätzlich `profile_geometrie.json` mit den vollständigen Profil- und Konturdaten.
- `fliesen.csv`: tatsächliche einzelne Fliesenformate einschließlich Eck-/Restzuschnitten; zusätzlich `fliesen_geometrie.json` mit Konturen und Einbaulage.
- `*.dxf`: reine 1:1-Kontur je Blech einschließlich Öffnungen, ohne Beschriftungen. `FL*.dxf` sind Fliesenkonturen; `AI*`/`AA*` die inneren/äußeren Auflager, `AS*` die Anschläge; `KD*.dxf` sind Seitenkonturen der diagonalen U-Profile.
- `*_bemassung.svg` und `schnittzeichnungen.html`: Außenmaße, Eckkoordinaten und Lage/Größe aller Öffnungen. Profilzuschnitte stehen als Maßtabelle im HTML.
- `querschnitt.dxf`: mittiger Beckenblech-Querschnitt, ohne Tragwerk und Fliesen.
- `rinnendetail.svg` und `rinnendetail.dxf`: Detailquerschnitt einschließlich Fliese und oberem Rahmen.
- `teile.json`, `openscad.log`, `exportparameter.json`: nachvollziehbare Geometrie und Eingabestand.
- `pruefhinweise.txt`: insbesondere Öffnungen über Teilungsnähten.

Farbgebung: Beckenwände hellblau, Boden blau, Mittelrinne grün, Überlaufrinne orange, U-Stützen rot, Diagonalen gelb, Randrahmen grau, Fliesen beige. Die cyanfarbenen Pfeile zeigen gewünschte Strömungsrichtungen. **STL speichert diese Farben nicht**; die farbige Darstellung ist im SCAD-Modell/F5 verfügbar. Darstellungsobjekte wie Pfeile, Fliesen und insbesondere `fertigungsplan_zeigen` vor einem reinen Becken-STL ausschalten.

## Was vor einer Bauanleitung noch fertig werden muss

Dieser Stand ist eine **parametrische Planungsgrundlage, keine freigegebene Schweiß- oder Bauanleitung**. Abstände und 2-/3-mm-V4A-Bleche orientieren sich an dem vom Autor beschriebenen Herstellerprinzip; Herstellerunterlagen und Tragfähigkeitsnachweise wurden nicht vorgelegt oder geprüft.

- **Freistehendes, freitragendes Becken:** Vollständiges Tragwerk einschließlich Bodenunterstützung, diagonaler Aussteifung, Lastpfad, Fußplatten, Befestigung und Auflager berechnen. Der gezeichnete U-Stützen-/Randrahmen-Aufbau ist ausdrücklich unvollständig und nicht statisch dimensioniert. Die Parameter passen Stückzahlen und Positionen an, nicht automatisch die erforderliche Tragfähigkeit. Die Vorlage zeigt Profile idealisiert ohne Biegeradien.
- **Überlauf mit Fliesen:** Die geneigten Auflager, der Anschlag und Eckgehrungen sind geometrisch enthalten. Noch fehlen Tragfähigkeitsnachweise für Fliesen, Auflagerstreifen, Rinnenboden und deren Schweißanschlüsse, Bettung/Toleranzausgleich, Anschluss an die Terrasse, Bemessung des Fugeneinlaufs, Längsgefälle der Rinne, Ausgleichsbehälter und Regelung. Die Fliesen sind entnehmbar gezeichnet. Eine Montage- oder Belastungsfreigabe ist damit nicht verbunden.
- **Mittige Absaugung:** Anschlüsse sind Platzhalter. Eine offene Rinne ist kein zugelassener Ansaugschutz. Abdeckung, Ansaugschutz, Pumpen/Leitungen und Betriebsfälle müssen gemeinsam ausgelegt werden. Allgemeine Hintergrundinformation zum Einklemm-/Ansaugrisiko: [CPSC – Pool and Spa Drain Covers](https://www.cpsc.gov/Business--Manufacturing/Business-Education/Business-Guidance/Pool-and-Spa-Drain-Covers). US-Hinweise sind hier keine österreichische Zulassungsgrundlage.
- **Hydraulik:** Düsenpfeile sind keine Simulation. Vollständige Durchströmung und der Transport von Schmutz in die Rinne werden nicht garantiert. Pumpendaten, Düsenkennlinien und reale Einbauteile sind erforderlich.
- **Fertigung:** Nennkonturen besitzen keine Schweißspalte, Wurzelspalte, Nahtvorbereitung, Schrumpfzugaben, Schnittfugenkompensation oder Toleranzkette. Eck-/Stoßdetails und Übergänge geneigter Bleche müssen vor Fertigung detailliert werden; Plattendicken sind modelliert, aber die Anschlüsse nicht als fertige Schweißdetails optimiert. Werkstoffnummer, Oberfläche, Wasserchemie und Schweiß-/Nachbehandlungsverfahren festlegen. „V4A“ allein ist keine eindeutige Bestellspezifikation.

## Veröffentlichung

Der Ordner ist als Ausgangspunkt für ein öffentliches Repository strukturiert. Er wurde **nicht zu GitHub hochgeladen**. Vor Veröffentlichung eine passende Lizenz für Software und Konstruktionsdaten wählen und Autorenschaft/Rechte der ursprünglichen Vorlage klären. Noch keine Lizenz unterstellt. Für freigegebene Varianten Eingaben, Prüfnachweise und Versionsstand gemeinsam archivieren. Geometrieexport und statische Bemessung sollten später getrennte, klar versionierte Module werden.
