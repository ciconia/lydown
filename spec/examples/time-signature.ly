\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    \time 2/4
    c4 d e f \time 3/4 g a b c2. \time 3/16
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
