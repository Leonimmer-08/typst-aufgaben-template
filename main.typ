#import "template.typ": conf, naechstes-blatt

#show: conf.with(
  module: "OVWL",
  name: "",
  matrikel: "",
  show-q: true,
  show-a: true,
  show-c: true // Hier kannst du z.B. global alle Korrekturen für das gesamte Dokument ausschalten
)

// Blatt 1 importieren
//#include "blatt/blatt_1.typ"

// Wechsel zu Blatt 2 (setzt intern die Nummer hoch und macht einen Seitenumbruch)
//#naechstes-blatt(2)
//#include "blatt/blatt_2.typ"

// Wechsel zu Blatt 5
//#naechstes-blatt(5)
//#include "blatt/blatt_5.typ"
