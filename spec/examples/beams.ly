\version "2.18.2"

"//music" = \relative c {
  << \new Voice = "voice1" {
    c4 d8[ e' f]\f
    \autoBeamOff
    g16 a32[ b] ges8.[ ais16]-. bes8.[ cis16]-.

    c8[( d e f]) g[( a b c])
    \autoBeamOn
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
