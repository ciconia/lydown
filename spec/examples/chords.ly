\version "2.18.2"

ldMusic = \relative c {
  << \new Voice = "voice1" {
    \key d \major
    g'16 a b g e4 <fis d>2
  } >>
}

\book {
  \header {
  }

  \score {
    <<
    \new Staff = Staff \with { }
    \context Staff = Staff {
      \ldMusic
    }
    >>
  }
}
