## Version 0.14.0 2016-06-28

- Remove support for Ruby 1.9.x.
- Refactor templating system.
- Add `\partPageBreak`, `\scorePageBreak` commands.
- Add heading_title setting for setting part title in heading.
- Add support for edition-specific settings (activated using `-e` switch).
- Add support for transpose setting.
- Properly render complex staff hierarchy (with proper staff groups).
- Add default settings for trumpet/tromba.
- Translate :| / |: bars to :|. / .|: respectively.
- Add `\scoreBreak` command (counterpart of `\partBreak`).
- Cleaner file structure.
- Add support for layout parameters (#11).

## Version 0.13.0 2016-03-10

- Remove lilypond installer (rely on lyp instead).
- Add support for repeats with alternatives.
- Improved translation of Ripple code.
- Add support for cross-bar augmentation dots.
- Add support for package loading.
- Remove house-style, goes in separate package.
- Switch to better syntax for grace notes.

## Version 0.12.4 2015-11-28

- Add support for Ruby 1.9.3.
- Add automatic build testing (https://travis-ci.org/ciconia/lydown).

## Version 0.12.3 2015-11-28

- Add support for Ruby < 2.1.0.

## Version 0.12.2 2015-11-28

- Cleanup compile messages.
- Do not try to process parts if none exist.
- Fix/update hello world example in README.

## Version 0.12.1 2015-11-28

- Detect passing a CLI command as an argument (e.g. lydown --version).

## Version 0.12.0 2015-11-28

- Add standalone releases of lydown for users who don't have ruby installed (#54).
- Add <code>lydown install</code> command for installing lilypond (#52).

## Version 0.11.0 2015-10-10

- Go into interactive mode when no command is given #50 (see README).
- Add support for including different files for score, part.

## Version 0.10.0 2015-09-20

- Add support for shorthand override commands #13.
- Add support for hiding bar numbers.
- Various improvements to proof mode.
- Add support for full bar silences #39.
- Cache results of parse and render stages for faster processing.
- Add support for mode specific code #21.
- Add support for including auxiliary parts in extracted parts.
- Add support for \partBreak command.
- Add support for includes (with templating for files with .ely extension) #41
- Add support for colla parte and part source settings #26
- Add support for custom part titles.
- Add support for score/part specific page breaks, using \bookpart sections.
- Add support for inline midi tempo (hidden tempo) #16
- Add support for blank extenders in bass figures, allow putting extender only at end of tenue, instead of on each note #18
- Fix rendering of note expressions.
- Render lilypond code using variables #8
- Add support for breve and longa values ('0' and 'l' respectively) #7
- Add support for smallcaps instrument name style, using the <code>instrument_name_style</code> setting.
- Prevent removal of continuo staff when empty_staves is set to <code>hide</code>.
- Add support for aligned note markup: <code>\<"right-aligned"</code>, <code>\>"left-aligned"</code>, <code>\|"centered"</code>.
- Add instrument_names setting for showing/hiding instrument names on first system. When set to inline, the instrument names are shown inline using the \instr command.
- Add \instr command for showing the instrument name inline, above the staff.
- Support for rehearsal marks with whitespace
- Change default bracing for split choir
- Fix rendering of <b> figure
- Add support for mp3 output format (using timidity & [LAME](http://lame.sourceforge.net/))
- Fix opening of MIDI output files (using [timidity](http://timidity.sourceforge.net/))
- Add include_parts parameter to proof mode
- Improve error reporting, beep on error in proof mode

## Version 0.9.0 2015-08-06
- Show progress bars when parsing/processing/compiling code (#4)
- Implement MIDI output #6
- Set default tagline
- Refactor work and work context code
- Parallelize parsing and translation of lydown code #5
- Fix rendering of macros with rests
- Improve Ripple code translation #1
- Use absolute octave marker for first note #3
- Add \prallupbefore command to stdlib

## Version 0.8.1 2015-07-22
- Fix proofing.

## Version 0.8.0 2015-07-22
- Refactor command line tool. The lydown command now accepts subcommands:
  compile (default), version, translate.
- Implement translation from Ripple into Lydown #1.

## Version 0.7.2 2015-07-15

- Better proof mode: point and click to go to lydown source.
- Better proof mode: output file always opened in the foreground.
- Better proof mode: always render to end of file.

## Version 0.7.1 2015-07-02

- Implement proof mode, watching files in subdirectories, and rendering the actual code that was changed.
- Fix tempo rendering in part mode.

## Version 0.7.0 2015-06-30

- Major refactor of command line code. The lydown command now correctly takes into account parts and movements filters, and correctly generates an output file even if there is a subdirectory with the same name.
- Accept accidentals characters #ßh, to allow for a more natural feel.
- Allow usage of ficta for cautionary/courtesy accidental.

## Version 0.6.5 2015-06-24

- Include a "standard" [lilypond lib](https://github.com/ciconia/lydown/blob/master/lib/lydown/rendering/lib.ly) in rendered lilypond code.
- Add support for partial rendering of duration macros. This allows the user to abandon the duration macro without writing a complete group, e.g. <code>{8____}cd4e<\code>
- Add support for commands while using duration macros.
- Fix usage of notes with expressions in duration macros.

## Version 0.6.4 2015-06-22

- Add support for grace notes (\grace, \appoggiatura, \acciaccatura).


## Version 0.6.3 2015-06-21

- Preserve settings in work.ld and movement.ld when processing files in subdirectories.
- Fix 16th note tuplets.

## Version 0.6.2 2015-06-17

- Add support for escaped quotes in commands and note markup.
- Fix full bar rests after duration macro.
- Add support for chords.

## Version 0.6.1 2015-06-13

- Fix using lyrics with multiple voices.
- When lyrics are used for multiple voices, lyrics for voice 1 and 3 are positioned above the staff.
- Fix inline clef changing.
- Add support for shorthand notation for key signature (upper case for major, lower case for minor).

## Version 0.6 2015-06-10

- empty_staves setting for hiding empty staves.
- inline lyrics, multiple stanzas using number in parens.
- multiple voices.

## Version 0.5 2015-06-07

- Basic note markup
- Fix simultaneous beam and slur
- Repeating pitch using @
- Ficta accidentals
- Tempo setting
- Inline commands and settings

## Version 0.4 2015-05-27

- Allow macro definition with or without curly braces
- Use alto clef as default for gambas
- Add support for empty inline figures, e.g. 4c8<><4>
- Support for alternative order of accidentals, octave marks, e.g. c'+
- Tuplets!

## Version 0.3 2015-05-17

- Bar lines
- Fixed lyrics rendering in scores
- Second stanzas for lyrics
- Support for unmetered music (time: unmetered)
- Support for invisible bar lines (line breaks for unmetered music) #10
- Named macros

## Version 0.2 2015-05-16

- Stream switching
- Inline figures

## Version 0.1 2015-05-10

- Durations, duration macros
- Comments
- Time signature, key signature, clefs
- Accidentals, accidental flags, octave markers
- Expression marks
- Lyrics
- Ties, slurs, Beams
- Basic command line functionality
- Multiple parts, multiple movements
- Score rendering, staff groups
- Full work directory processing
