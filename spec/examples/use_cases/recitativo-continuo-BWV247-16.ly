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
          c1
          b2 bes
        } >>
      }
    }
    \figures { <_->2 <4+> <6> <6> }
    >>
  }
}