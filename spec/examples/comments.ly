\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    c4 d e f
    %{this is a comment on a separate line%}
    g a b c
    %{this is a comment at the end of a line%}
    \time 4/4
    %{this is a comment on a setting line%}
    d
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
