\version "2.18.2"
#(define lydown:render-mode 'part)

"//music" = \relative c {
  << \new Voice = "voice1" {
    c4 e8 g c2
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
            \set Score.skipBars = ##t
            \"//music"
          }
          >>
        >>
      >>
      \layout { }
    }
  }
}
