\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    c4 d e f
  } >>
}

\book {
  \header {
  }

  \bookpart { 
    \score {
      <<
      \new Staff = Staff \with { }
      \context Staff = Staff {
        \tempo "Allegretto"
        \"//music"
      }
      >>
    }
  }
}
