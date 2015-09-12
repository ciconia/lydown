\version "2.18.2"

"/violino1/music" = \relative c {
  << \new Voice = "violino1_voice1" {
    \key fis \minor fis1
    \key d \minor f
  } >>
}
"/continuo/music" = \relative c {
  << \new Voice = "continuo_voice1" {
    \key fis \minor cis1
    \key d \minor c
  } >>
}

\book {
  \header {
  }

  \bookpart { 
    \score {
      \new StaffGroup << 
        \set StaffGroup.systemStartDelimiterHierarchy = #'(SystemStartBar violino1 continuo )
      
        <<
        \new Staff = ViolinoIStaff \with { }
        \context Staff = ViolinoIStaff {
          \clef "treble"
          \"/violino1/music"
        }
        >>

        <<
        \new Staff = ContinuoStaff \with { \override VerticalAxisGroup.remove-empty = ##f }
        \context Staff = ContinuoStaff {
          \clef "bass"
          \"/continuo/music"
        }
        >>
      >>
    }
  }
}
