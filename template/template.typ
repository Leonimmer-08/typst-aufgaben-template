#import "@preview/lilaq:0.6.0" as lq
// --- ZUSTÄNDE (STATES) ---
#let show-q-state = state("show-q-state", true)
#let show-a-state = state("show-a-state", true)
#let show-c-state = state("show-c-state", true)
#let show-sc-state = state("show-sc-state", true)
#let sheet-state = state("sheet-state", 1) // NEU: Dynamische Blattnummer
#let qa-counter = counter("qa-counter")
// --- CONFIGURATION FUNCTION ---
#let conf(
  module: "Modulname",
  name: "Vorname Nachname",
  matrikel: "1234567",
  show-q: true,
  show-a: true,
  show-c: true,
  show-sc: true,
  logo-path: none,
  language: "de",
  body
) = {
  show-q-state.update(show-q)
  show-a-state.update(show-a)
  show-c-state.update(show-c)
  show-sc-state.update(show-sc)

  set document(title: module, author: name)
  set text(lang: language)

  show heading.where(level: 1): it => [
    #qa-counter.update(0)
    #it
  ]

  show image: i => [
    
    #figure(caption: i.alt, supplement: "Image", kind: "Image")[#i]
  ]

  
  set page(
    margin: (top: 3.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    header: context {
      let page-num = here().page()
      let current-sheet = sheet-state.get() // Holt die aktuelle Blattnummer
      
      grid(
        columns: (1fr, auto, 1fr),
        align(left + horizon)[*#name* \ Matrikelnr.: #matrikel],
        align(center + horizon)[*#module* \ Blatt #current-sheet], // Dynamisch!
        align(right + horizon)[
          #if page-num == 1 {
            if logo-path != none {
              image(logo-path, width: 4cm)
            } else {
              rect(width: 4cm, height: 1.2cm, stroke: 0.5pt, radius: 2pt)[
                #align(center + horizon)[Logo Platzhalter]
              ]
            }
          }
        ]
      )
      v(-0.5em)
      line(length: 100%, stroke: 0.5pt)
    },
    footer: context {
      line(length: 100%, stroke: 0.5pt)
      v(0.2em)
      align(center)[Seite #counter(page).display()]
    }
  )

  set text(font: "Linux Libertine", size: 11pt)
  body
}

// NEU: Hilfsfunktion für den Wechsel zum nächsten Blatt

// Korrigierte Reihenfolge für den Arbeitsblatt-Zähler
#let naechstes-blatt(nr) = [
  #sheet-state.update(nr) // 1. Zuerst intern das Blatt hochzählen
  #pagebreak(weak: true)  // 2. Dann die neue Seite anfangen
  #counter(page).update(1)// 3. Seitenzahl wieder auf 1 setzen
]
// [Die restlichen Funktionen (frage, antwort, single-choice) bleiben exakt gleich wie vorher]

// --- BLÖCKE UND FUNKTIONEN ---

// Fragenblock (Blau)
#let frage(body) = context {
  // Das .get() ist hier sicher, da die gesamte Funktion ein context {} ist
  if show-q-state.get() {
    block(
      fill: rgb("#e6f2ff"),
      stroke: rgb("#005ce6"),
      inset: 12pt,
      radius: 4pt,
      width: 100%,
    )[*Frage:* \ #body]
  }
}

#let antwort(body) = context {
  if show-a-state.get() {
    block(
      fill: rgb("#e6ffe6"),
      stroke: rgb("#00b300"),
      inset: 12pt,
      radius: 4pt,
      width: 100%,
    )[*Antwort:* \ #body]
  }
}
// Korrektur (Rot, Kursiv)
#let korrektur(body) = context {
  if show-c-state.get() {
    text(fill: red, style: "italic")[#body]
  }
}


// Single-Choice Block (Roter Hintergrund, Kästchen rechts, neue Syntax)
#let single-choice(correct: none, description, ..options) = context {
  // options.pos() wandelt alle weiteren aneinandergereihten [...] in ein Array um
  let opts = options.pos() 
  
  let items = opts.enumerate().map(((i, opt)) => {
    let is-checked = (i + 1 == correct) and show-sc-state.get()
    
    let box-content = if is-checked {
      text(weight: "bold")[#sym.checkmark]
    } else {
      " "
    }
    
    // Grid: Text links (1fr), Kästchen rechts (auto)
    grid(
      columns: (1fr, auto),
      align(left + horizon)[#opt],
      align(right + horizon)[#box(width: 12pt, height: 12pt, stroke: 1pt, radius: 2pt, align(center+horizon)[#box-content])]
    )
  })

  block(
    fill: rgb("#fff0f0"),  
    stroke: rgb("#cc0000"), 
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    stack(
      dir: ttb,
      spacing: 12pt,
      // Beschreibung oben (hier leicht hervorgehoben)
      text(weight: "bold")[#description],
      
      // Die Antwortmöglichkeiten darunter
      grid(
        columns: 1,
        row-gutter: 10pt,
        ..items
      )
    )
  )
}



#let q(body) = context {
  // 1. Zählerstand exakt JETZT abrufen und selbst +1 rechnen
  let current = qa-counter.get().first() + 1
  
  // 2. Den passenden Buchstaben als Text generieren
  let letter = numbering("a)", current)
  
  // 3. Dem System den neuen Wert aufzwingen UND die Box ausgeben
  [
    #qa-counter.update(current)
    #frage[*#letter* #body]
  ]
}

#let a(body) = context {
  // 1. Den exakten Zählerstand abrufen (ohne hochzuzählen)
  let current = qa-counter.get().first()
  
  let letter = numbering("a)", current)
  
  // 2. Die Box ausgeben
  antwort[*#letter* #body]
}

// Setzt den qa-counter bei jeder Level-1-Überschrift (=) automatisch zurück

