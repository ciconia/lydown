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
          \key c \major
          c4 d e f
          \key a \minor
          g a b c
          %{only the f+ minor key signature will be rendered%}
          \key fis \minor
        } >>
      }
    }
    >>
  }
}
