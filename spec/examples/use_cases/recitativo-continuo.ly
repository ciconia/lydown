\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    e4 r r2 R1*1 g4 r r2 fis4 r r2 fis4 r r2 e4 a r g R1*1 fis4 r b r
  } >>
}
"//figures" = \figuremode { <_+>4 s s2 s1*1 <4+ 2>4 s s2 <7 _+>4 s s2 <6 4>4 s s2 <_+>4 s s <4+ 2+> s1*1 <_+>4 }

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
          \new FiguredBass { \"//figures" }
          >>
        >>
      >>
      \layout { }
    }
  }
}
