\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    b'8
    c4 e8 g c2
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
        \partial 8
        \"//music"
      }
      >>
    }
  }
}
