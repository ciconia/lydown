\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    cis'4 ~ cis ges2
    ges16-- ges ges ges
    c4 d8 ees,4 ees8
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
