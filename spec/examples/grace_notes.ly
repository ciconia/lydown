\version "2.18.2"

\book {
  \header {
  }

  \bookpart {
    <<
    \new Staff = Staff \with { }
    \context Staff = Staff {
      \relative c {
        << \new Voice = "voice1" {
          r8 \acciaccatura { c16 d } e8 d16[ c] b[ a] g[ e] f8 r d
          
        r f \appoggiatura { e16 } d8 \appoggiatura { c16 } b8 g8. b16 d[ c] d8
        } >>
      }
    }
    >>
  }
}
