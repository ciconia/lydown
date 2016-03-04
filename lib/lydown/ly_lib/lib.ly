\header {
  tagline = ##f
}

segno = {
  \once \override Score.RehearsalMark #'font-size = #-2
  \mark \markup { \musicglyph #"scripts.segno" }
}

segnobottom = {
  \once \override Score.RehearsalMark #'direction = #DOWN
  \once \override Score.RehearsalMark #'font-size = #-2
  \mark \markup { \musicglyph #"scripts.segno" }
}

dalsegno = {
  \once \override Score.RehearsalMark #'break-visibility = #begin-of-line-invisible
  \once \override Score.RehearsalMark #'direction = #DOWN
  \once \override Score.RehearsalMark #'self-alignment-X = #RIGHT
  \once \override Score.RehearsalMark #'font-size = #-2
  \mark \markup { \fontsize #2 {"dal segno "} \musicglyph #"scripts.segno" }
}

dacapo = {
  \once \override Score.RehearsalMark #'break-visibility = #begin-of-line-invisible
  \once \override Score.RehearsalMark #'direction = #DOWN
  \once \override Score.RehearsalMark #'self-alignment-X = #RIGHT
  \mark \markup {\bold {\italic {"Da capo"}}}
}

dalsegnoadlib = {
  \once \override Score.RehearsalMark #'direction = #DOWN
  \once \override Score.RehearsalMark #'self-alignment-X = #LEFT
  \once \override Score.RehearsalMark #'font-size = #-2
  \mark \markup { \musicglyph #"scripts.segno" ad lib }
}

finedellaparteprima = {
  \once \override Score.RehearsalMark #'break-visibility = #begin-of-line-invisible
  \once \override Score.RehearsalMark #'direction = #DOWN
  \once \override Score.RehearsalMark #'self-alignment-X = #RIGHT
  \mark \markup {\bold {\italic {"Fine della parte prima"}}}
}

padbarlinebefore = {
  \once \override Staff.BarLine #'extra-spacing-width = #'(-2 . 0)
}

padbarlineafter = {
  \once \override Staff.BarLine #'extra-spacing-width = #'(0 . 2)
}

editF = \markup { \center-align \concat { \bold { \italic ( }
  \dynamic f \bold { \italic ) } } }
editP = \markup { \center-align \concat { \bold { \italic ( }
  \dynamic p \bold { \italic ) } } }
editPP = \markup { \center-align \concat { \bold { \italic ( }
  \dynamic pp \bold { \italic ) } } }
  
doux = \markup { \center-align \bold { \italic doux }}
fort = \markup { \center-align \bold { \italic fort }}

ten = \markup { \italic ten. }

ficta = {
  \once \override AccidentalSuggestion #'avoid-slur = #'outside
  \once \set suggestAccidentals = ##t
}

%{
  http://www.lilypond.org/doc/v2.18/Documentation/snippets/editorial-annotations#editorial-annotations-adding-links-to-objects
%}
#(define (add-link url-strg)
  (lambda (grob)
    (let* ((stil (ly:grob-property grob 'stencil)))
      (if (ly:stencil? stil)
        (begin
          (let* (
             (x-ext (ly:stencil-extent stil X))
             (y-ext (ly:stencil-extent stil Y))
             (url-expr (list 'url-link url-strg `(quote ,x-ext) `(quote ,y-ext)))
             (new-stil (ly:stencil-add (ly:make-stencil url-expr x-ext y-ext) stil)))
          (ly:grob-set-property! grob 'stencil new-stil)))
        #f))))
        

\layout {
  \context {
    \Score
    \override InstrumentName #'self-alignment-X = #right
    \override InstrumentName #'padding = 0.6
    
    \override BarNumber #'padding = 1.5
    
%     \override Stem #'details #'beamed-minimum-free-lengths = #'(1.83 1.5 1.25)

    %make note stems a bit thicker
    \override Stem.thickness = #(lambda (grob) (+ 1.8 (* 0.05 (random:normal))))
    
    % slurs and ties are a bit curvier and thicker
    % ties are also a bit more distant from note heads
    % all that with a bit of randomness
    \override Slur.eccentricity = #(lambda (grob) (* 0.05 (random:normal)))
    \override Slur.height-limit = #(lambda (grob) (+ 2.8 (* 0.2 (random:normal))))
    \override Slur.thickness = #(lambda (grob) (+ 2.9 (* 0.1 (random:normal))))
    \override Slur.ratio = #(lambda (grob) (+ 0.3 (* 0.05 (random:normal))))

    \override Tie.thickness = #(lambda (grob) (+ 2.9 (* 0.1 (random:normal))))
    \override Tie.ratio = #(lambda (grob) (+ 0.3 (* 0.05 (random:normal))))
    \override Tie #'details #'note-head-gap = #(lambda (grob) (+ 0.5 (* 0.1 (random:normal))))
    
    \override Beam.beam-thickness = #(lambda (grob) (+ 0.55 (* 0.02 (random:normal))))
    \override Beam.length-fraction = #1.15
    
%     \remove "Bar_number_engraver"
  }
  
  \context {
    \Staff
    \override StaffSymbol.color = #(rgb-color 0.25 0.2 0.2)
    
    \override VerticalAxisGroup.default-staff-staff-spacing = #'(
      (basic-distance . 50)
      (minimum-distance . 9)
      (padding . 5)
      (stretchability . 20)
    )
  }
  
  \context {
    \Lyrics
    % candidates: Georgia, Hoefler Text, Hoefler Text Italic,
    % 
    \override LyricText #'font-name = #"Hoefler Text"
%     \override LyricText #'font-size = #3
  }
  
  \context {
    \override MarkupText #'font-name = #"Hoefler Text"
  }
}

\paper {
  #(set-default-paper-size "a4" 'landscape)

  #(layout-set-staff-size 14)

  indent = 0\cm

  top-margin = 10\mm
  bottom-margin = 10\mm
  two-sided = ##t
  inner-margin = 8.75\mm
  outer-margin = 17.5\mm
  binding-offset = 0\mm
  
  markup-system-spacing #'padding = #3
  markup-system-spacing #'stretchability = #10
  score-markup-spacing #'padding = #7
  top-markup-spacing #'padding = #3

  system-system-spacing #'minimum-distance = #12
  system-system-spacing #'padding = #9
  system-system-spacing #'stretchability = #15


  top-staff-margin = 24.5\mm
  bottom-staff-margin = 24.5\mm

  % set distance of top staff relative to margin
  top-system-spacing #'basic-distance = #(+ (/ (- top-staff-margin top-margin) staff-space) 2)
  top-system-spacing #'minimum-distance = #(+ (/ (- top-staff-margin top-margin) staff-space) 2)
  top-system-spacing #'padding = -50 % negative padding to ignore skyline
  top-system-spacing #'stretchability = 0 % fixed position

  % set distance of top staff relative to margin
  bottom-last-spacing #'basic-distance = #(+ (/ (- bottom-staff-margin bottom-margin) staff-space) 2)
  bottom-last-spacing #'minimum-distance = #(+ (/ (- bottom-staff-margin bottom-margin) staff-space) 2)
  bottom-last-spacing #'padding = -50 % negative padding to ignore skyline
  bottom-last-spacing #'stretchability = 0 % fixed position

%
%
%
%   top-system-spacing #'basic-distance = #2
%   top-system-spacing #'minimum-distance = #0
%   top-system-spacing #'padding = #-10
%   top-system-spacing #'stretchability = #0
  
  
%   ragged-last-bottom = ##t
%   ragged-bottom = ##t
  
  print-first-page-number = ##f
  
  oddHeaderMarkup = \markup \on-the-fly #not-first-page \fill-line {
     \null \fromproperty #'page:page-number-string
  }

  evenHeaderMarkup = \markup \fill-line {
    \fromproperty #'page:page-number-string \null
  }
}

% trill = #(make-articulation "stopped")
trillSharp = #(make-articulation "trillSharp")
trillNatural = #(make-articulation "trillNatural")
tr = #(make-articulation "t")
trillSug = #(make-articulation "trillSug")
prallSug = #(make-articulation "prallSug")
arcTrill = #(make-articulation "arcTrill")
arcDot = #(make-articulation "arcDot")
arcArc = #(make-articulation "arcArc")
arcArcDot = #(make-articulation "arcArcDot")
dotDot = #(make-articulation "dotDot")
dotPrall = #(make-articulation "dotPrall")
dotDoublePrallDoublePrall = #(make-articulation "dotDoublePrallDoublePrall")
doublePrall = #(make-articulation "doublePrall")

prallupbefore = {
  \mark\markup {
    \musicglyph #"scripts.prallup"
    \hspace #1 
  }
}

% override the figured bass formatter in order to fix size of figure accidentals
#(define-public (better-format-bass-figure figure event context)
  (let* ((fig (ly:event-property event 'figure))
         (fig-markup (if (number? figure)

                         ;; this is not very elegant, but center-aligning
                         ;; all digits is problematic with other markups,
                         ;; and shows problems in the (lack of) overshoot
                         ;; of feta-alphabet glyphs.
                         ((if (<= 10 figure)
                              (lambda (y) (make-translate-scaled-markup
                                           (cons -0.7 0) y))
                              identity)

                          (cond
                           ((eq? #t (ly:event-property event 'diminished))
                            (markup #:slashed-digit figure))
                           ((eq? #t (ly:event-property event 'augmented-slash))
                            (markup #:backslashed-digit figure))
                           (else (markup #:number (number->string figure 10)))))
                         #f))

         (alt (ly:event-property event 'alteration))
         (alt-markup
          (if (number? alt)
              (markup
               #:general-align Y DOWN #:fontsize
               (if (not (= alt DOUBLE-SHARP))
                   0 2)
               (alteration->text-accidental-markup alt))
              #f))

         (plus-markup (if (eq? #t (ly:event-property event 'augmented))
                          (markup #:number "+")
                          #f))

         (alt-dir (ly:context-property context 'figuredBassAlterationDirection))
         (plus-dir (ly:context-property context 'figuredBassPlusDirection)))

    (if (and (not fig-markup) alt-markup)
        (begin
          (set! fig-markup (markup #:left-align #:pad-around 0.2 alt-markup))
          (set! alt-markup #f)))


    ;; hmm, how to get figures centered between note, and
    ;; lone accidentals too?

    ;;    (if (markup? fig-markup)
    ;;  (set!
    ;;   fig-markup (markup #:translate (cons 1.0 0)
    ;;                      #:center-align fig-markup)))

    (if alt-markup
        (set! fig-markup
              (markup #:put-adjacent
                      X (if (number? alt-dir)
                            alt-dir
                            LEFT)
                      fig-markup
                      #:pad-x 0.2 #:lower 0.1 alt-markup)))

    (if plus-markup
        (set! fig-markup
              (if fig-markup
                  (markup #:put-adjacent
                          X (if (number? plus-dir)
                                plus-dir
                                LEFT)
                          fig-markup
                          #:pad-x 0.2 plus-markup)
                  plus-markup)))

    (if (markup? fig-markup)
        (markup #:fontsize 0 fig-markup)
        empty-markup)))

\layout {        
  \context { 
    \FiguredBass 
    figuredBassFormatter = #better-format-bass-figure
%     \override BassFigure #'font-size = #-1
%     \override BassFigure #'font-name = #"Georgia"
  }
  
%   \context {
%     \StaffGroup
%     \override StaffGrouper.staff-staff-spacing =
%       #'((basic-distance . 10)
%          (minimum-distance . 7)
%          (padding . 0)
%          (stretchability . 7))
%
%   }
}
