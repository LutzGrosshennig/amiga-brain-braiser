# amiga-brain-braiser
An Amiga Game I wrote back in 1990!


BRAIN BRAISER.

Brain Braiser ist ein Denk- und Strategiespiel.
Es wird ein 12 * 13 Kästchen großes Spielfeld aufgebaut und mit Zufallszahlen
zwischen -9 und +9, sowie zwei Arten von Sonderfeldern gefüllt. Der Spieler 1
kann sich in diesen Spielfeld jeweils waagerecht bewegen, im Gegensatz dazu,
bewegt sich der Spieler 2 immer nur senkrecht.
Sinn des Spiels ist es eine möglichst hohe Punktzahl zu erreichen.
Die einfachste Möglichkeit dies zu erreichen ist, jeweils die höchste Wertung
der aktuellen Reihe bzw. Spalte zu besetzen, allerdings wird man dann das Spiel
sehr schnell verlieren, da Ihr Gegenspieler dann mehr als 5 Züge im voraus
planen kann, wo er Sie hinlocken will. Eine laufende Uhr begrenzt die Zugzeit,
so das bei kleiner Zeiteinstellung sehr schnell gehandelt werden muss.
Zusätzliche Felder können strategisch eingesetzt werden. Das wären zum einen die
Xchange Felder (durch ein großes X gekennzeichnet), die ein vertauschen der
Punktzahlen von Spieler 1 und Spieler 2 bewirken, so das ein Spieler der mit der
Punktezahl im Rückstand ist, seinem Rivalen seine schwer verdienten Punkte
"wegmoppsen" kann.
Zum anderen gibt es noch Zero Felder (Feldinhalt ist eine 0), diese bewirken,
daß die Vorzeichen im ganzen Spielfeld vertauscht werden (-9 wird 9 etc.).
Sollte die Uhr für einen Spieler abgelaufen sein, erhält der andere Spieler
einen Bonus von 15 Punkten, und den nächsten Zug. Sollte ein Spieler nicht
mehr ziehen können, da seine Reihe, Spalte komplett belegt ist, erhält sein
Kontrahent einen Bonus von 25 Punkten, anschließend wird das Spiel beendet.

Das Setup Menü.

Im Setup Menü, das vor jeden Neubeginn des Spieles erscheint, können Sie
einstellen, ob sie gegen denn Computer spielen wollen, oder einen menschlichen
Gegner vorziehen. Desweiteren können Sie die Art der Steuerung für jeden Spieler
separat festlegen. In einem String-Gadget können Sie außerdem komfortabel
die maximale Zugdauer einstellen (Voreingestellt 400 / entspricht 8 sek.).
Wollen Sie die Uhr selbst stellen, dann beachten Sie bitte folgendes, die Uhr
wird 50 Mal in der Sekunde um eins herunter gezählt. Sie müssen also die Zeit
in Sekunden mal 50 nehmen, um denn korrekten Wert für die Uhr zu erhalten.
Darüber hinaus können Sie die Anzahl der vorhandenen Joysticks festlegen.

Die Steuerung.

Spieler 1 steuert den Cursor mit den Tasten Alt links, Amiga links und der
Leertaste, oder über einen Joystick in Port 2.
Spieler 2 steuert den Cursor mit den Pfeiltasten hoch und runter, sowie mit
der Leertaste, oder über einen Joystick in Port 2. Sind zwei Joysticks
vorhanden und eingestellt, so benutzt Spieler 1 den Joystick in Port 2 und
Spieler 2 den Joystick in Port 1.

Sondertasten.

Mit der P Taste wird der Pause Modus aktiviert bzw. deaktiviert. Mit der
ESC Taste kann das Spiel jederzeit abgebrochen werden.

Der Computer.

Wollen Sie gegen den Computer spielen, so übernimmt dieser grundsätzlich die
Rolle des 2. Spielers, daß heißt er spielt immer senkrecht. Da der Algorithmus
des Computergegners nicht sehr umfangreich ist (damit Sie weniger Abtippen
müssen), hat er eine entscheidene Vergünstigung erhalten, daß X-Feld zählt für
ihn 10 Punkte, anstatt wie bei einem menschlichen Spieler, ein vertauschen der
Punktzahlen zu bewirken.
Desweiteren springt der Computer sein Zielfeld immer direkt an, was einen
gewissen Überraschungseffekt für den unaufmerksamen Spieler hat.

Allgemeines.

Auf eine High-Score Liste habe ich verzichtet als ich bemerkte, daß die 
erreichten Punktzahlen teilweise erheblich voneinander differierten. Das 
kommt dadurch zustande, daß das Spielfeld mit Zufallszahlen gefüllt wird,
es kann also durchaus vorkommen, daß keine einzige 9, ob plus oder minus,
im Spiel vorkommt, also keine große Chance auf eine hohe Punktzahl vorhanden
ist. Dadurch ist die erreichte Punktzahl mehr vom Zufall als vom Können des
jeweiligen Spielers abhängig.
Das Spiel hat aber dafür einen gewissen Lerneffekt, wenn man es oft spielt,
ist man später in der Lage eine ganze Reihe von Informationen (hier Werte)
auf einmal wahrzunehmen und zu verarbeiten.

Zum Programm. 

Das Programm ist 100%ig in Assembler (Profimat Amiga) geschrieben. Wodurch
ein sehr kurzes und kompaktes Programm möglich war (ca. 18 kB bzw. ca. 8 kB
gepackt). Das Programm ist auch in zwei sogenannte Hunks aufgeteilt die
beim Laden des Programms automatisch den Programmcode in mögliches
FAST-RAM, und die Grafik- und Sound-Daten ins CHIP-RAM laden.
Während des Spiels ist das Multitasking ausgeschaltet. Befinden Sie sich
allerdings im Setup oder Game-Over Modus ist das Multitasking wieder aktiv.
Auch wird nach dem Verlassen des Programms alles sorgfältig aufgeräumt, so das
Sie das Spiel mal nebenbei laden können, ohne befürchten zu müssen, daß Sie
nach dem verlassen des Programms Besuch von einen Herren aus Indien bekommen
(GURU !!!).
Da mit einer Ausnahme ausschließlich Betriebssytemroutinen (reichen für diese
Art von Spiel vollkommen aus), verwendet wurden, dürfte es keine 
Kompatibilitäts Schwierigkeiten mit neueren KICKSTARTs (1.3/2.0) oder
eventuellen Turbokarten geben. Die oben erwähnte Ausnahme besteht in der 
Initialisierung des Vertikal Blanking Interrupts (Tritt immer auf wenn der
Bildschirm neu auf dem Monitor gezeichnet wird. 50 mal / Sekunde bei PAL
Amigas ), die ich "zu Fuß" programmiert habe, da die Routine aber erst 
aufgerufen wird, nachdem das Multitasking ausgeschaltet ist, sollte es auch hier
keine Probleme geben. (Die alte Interrupt Adresse wird abgesichert und nach
verlassen des Programms wieder installiert).  
Sollten Sie vorhaben den Quellcode mit Ihren Assembler zu übersetzen, müssen 
sie folgendes beachten : Der Befehl ALIGN ist ein Äquivalent zum Befehl EVEN
der von dem meisten Assemblern benutzt wird. Ansonsten müssen Sie im Ihren
Handbuch nachschlagen, der Befehl bewirkt das der nachfolgende Quellcode
auf eine gerade Adresse gesetzt wird. Es ist desweiteren der Befehl IBYTES
verwendet wurden, der eine Spezialität des Profimats darstellt, mit ihm kann
man Daten direkt in den Quellcode integrieren. Da ich mich mit anderen
Assemblern nicht auskenne, weiß ich auch keine Lösung für dieses Problem,
aber vielleicht hat ja einer der Leser eine Idee.
Zum Schluß noch ein Tip, wenn Sie zwei Joysticks verwenden, können Sie den 
Mauspointer auch über die Tastatur steuern (rechte Amigataste + Pfeiltasten,
für größere Distanzen zusätzlich die rechte Shifttaste.), das
erspart Ihnen das lästige umstöpseln zwischen Maus und Joystick.
Ansonsten wünsche ich Ihnen viel Spaß mit dem Programm.

Lutz Großhennig                               Schwanewede, den 29.06.1990
