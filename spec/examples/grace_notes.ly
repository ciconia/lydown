\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    r8 \acciaccatura { c16 d } e8 d16[ c] b[ a] g[ e] f8 r d

  r f \grace { e16 } d8 \appoggiatura { c16 } b8 g8. b16 d[ c] d8
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
