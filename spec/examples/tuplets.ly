\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    c4 \tuplet 3/2 4 { d8 e f g f e } d4

    \tuplet 5/4 2 { c8 d e f g }

    \tuplet 3/2 8 { e16 d e f e f }
  } >>
}

\book {
  \header {
  }

  \bookpart {
    \score {
      \new OrchestraGroup \with { } <<
        \new StaffGroup \with { \consists "Bar_number_engraver" } <<
          <<
          \new Staff = Staff \with { }
          \context Staff = Staff {
            \"//music"
          }
          >>
        >>
      >>
      \layout { }
    }
  }
}
