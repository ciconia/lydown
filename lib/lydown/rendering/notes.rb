require 'lydown/rendering/figures'

module Lydown::Rendering
  module Accidentals
    KEY_CYCLE = %w{c- g- d- a- e- b- f c g d a e b f+ c+ g+ d+ a+ e+ b+}
    C_IDX = KEY_CYCLE.index('c'); A_IDX = KEY_CYCLE.index('a')
    SHARPS_IDX = KEY_CYCLE.index('f+'); FLATS_IDX = KEY_CYCLE.index('b-')
    KEY_ACCIDENTALS = {}

    def self.accidentals_for_key_signature(signature)
      KEY_ACCIDENTALS[signature] ||= calc_accidentals_for_key_signature(signature)
    end

    SIGNATURE_ACCIDENTAL_TRANSLATION = {
      '#' => '+',
      'ß' => '-'
    }

    def self.calc_accidentals_for_key_signature(signature)
      signature = signature.gsub(/[#ß]/) {|c| SIGNATURE_ACCIDENTAL_TRANSLATION[c]}
      unless signature =~ /^([a-g][\+\-]*) (major|minor)$/
        raise "Invalid key signature #{signature.inspect}"
      end

      key = $1; mode = $2

      # calculate offset from c major / a minor
      base_idx = (mode == 'major') ? C_IDX : A_IDX
      offset = KEY_CYCLE.index(key) - base_idx

      if offset >= 0
        calc_accidentals_map(KEY_CYCLE[SHARPS_IDX, offset])
      else
        calc_accidentals_map(KEY_CYCLE[FLATS_IDX + offset + 1, -offset])
      end
    end

    def self.calc_accidentals_map(accidentals)
      accidentals.inject({}) { |h, a| h[a[0]] = (a[1] == '+') ? 1 : -1; h}
    end
    
    ACCIDENTAL_VALUES = {
      '+' => 1,
      '-' => -1,
      '#' => 1,
      'ß' => -1
    }

    def self.lilypond_note_name(note, key_signature = 'c major')
      # if the natural sign (h) is used, no need to calculate the note name
      return $1 if note =~ /([a-g])h/
        
      value = 0
      # accidental value from note
      note = note.gsub(/[\-\+#ß]/) { |c| value += ACCIDENTAL_VALUES[c]; '' }
        
      # add key signature value
      value += accidentals_for_key_signature(key_signature)[note] || 0

      note + (value >= 0 ? 'is' * value : 'es' * -value)
    end
    
    def self.chromatic_to_diatonic(note, key_signature = 'c major')
      note =~ /([a-g])([\+\-]*)/
      diatonic_note = $1
      chromatic_value = $2.count('+') - $2.count('-')
      
      key_accidentals = accidentals_for_key_signature(key_signature)
      diatonic_value = key_accidentals[diatonic_note] || 0
      value = chromatic_value - diatonic_value
      
      "#{diatonic_note}#{value >= 0 ? '+' * value : '-' * -value}"
    end

    # Takes into account the accidentals mode
    def self.translate_note_name(work, note)
      if work[:accidentals] == 'manual'
        key = 'c major'
      else
        key = work[:key]
      end
      lilypond_note_name(note, key)
    end
  end
  
  module Octaves
    # calculates the octave markers needed to put a first note in the right 
    # octave. In lydown, octaves are relative (i.e. lilypond's relative mode).
    # But the first note gives the octave to start on, rather than a relative 
    # note to c (or any other reference note).
    #
    # In that manner, d' is d above middle c, g'' is g an octave and fifth 
    # above middle c, a is a a below middle c, and eß, is great e flat.
    # 
    # The return value is a string with octave markers for relative mode,
    # based on the refence note
    DIATONICS = %w{a b c d e f g}
    def self.relative_octave(note, ref_note = 'c')
      note_diatonic, ref_diatonic = note[0], ref_note[0]
      raise LydownError, "Invalid note #{note}" unless DIATONICS.index(note_diatonic)
      raise LydownError, "Invalid reference note #{ref_note}" unless DIATONICS.index(ref_diatonic)
      
      # calculate diatonic interval
      note_array = DIATONICS.rotate(DIATONICS.index(ref_diatonic))
      interval = note_array.index(note_diatonic)

      # calculate octave interval and 
      octave_value = note.count("'") - note.count(',')
      ref_value = ref_note.count("'") - ref_note.count(',')
      octave_interval = octave_value - ref_value
      octave_interval += 1 if interval >= 4
      
      # generate octave markers
      octave_interval >= 0 ? "'" * octave_interval : "," * -octave_interval
    end
  end

  module Notes
    include Lydown::Rendering::Figures

    def add_note(event, options = {})
      return add_macro_note(event) if @work['process/duration_macro']
      
      # calculate relative octave markers for first note
      unless @work['process/first_note'] || event[:head] =~ /^[rsR]/
        note = event[:head] + (event[:octave] || '')
        event[:octave] = Lydown::Rendering::Octaves.relative_octave(note)
        @work['process/first_note'] = note
      end
      
      if event[:head] == '@'
        # replace repeating note head
        event[:head] = @work['process/last_note_head'] 
      else
        @work['process/last_note_head'] = event[:head]
      end

      value = @work['process/duration_values'].first
      @work['process/duration_values'].rotate!

      add_figures(event[:figures], value) if event[:figures]

      # push value into running values accumulator. This is used to synthesize
      # the bass figures durations.
      unless event[:figures]
        @work['process/running_values'] ||= []
        if event[:rest_value]
          @work['process/running_values'] << event[:rest_value]
        else
          @work['process/running_values'] << value
        end
      end

      # only add the value if different than the last used
      if options[:no_value] || (value == @work['process/last_value'])
        value = ''
      else
        @work['process/last_value'] = value
      end

      if event[:line] && @work['options/proof_mode']
        @work.emit(event[:stream] || :music, note_event_url_link(event))
        # @work.emit(event[:stream] || :music, "%{#{event[:line]}:#{event[:column]}%}")
      end

      code = lilypond_note(event, options.merge(value: value))
      @work.emit(event[:stream] || :music, code)
    end
    
    def add_chord(event, options = {})
      value = @work['process/duration_values'].first
      @work['process/duration_values'].rotate!

      add_figures(event[:figures], value) if event[:figures]

      # push value into running values accumulator. This is used to synthesize
      # the bass figures durations.
      unless event[:figures]
        @work['process/running_values'] ||= []
        if event[:rest_value]
          @work['process/running_values'] << event[:rest_value]
        else
          @work['process/running_values'] << value
        end
      end

      # only add the value if different than the last used
      if value == @work['process/last_value']
        value = ''
      else
        @work['process/last_value'] = value
      end
      
      notes = event[:notes].map do |note|
        lilypond_note(note)
      end
      
      options = options.merge(value: value)
      @work.emit(event[:stream] || :music, lilypond_chord(event, notes, options))
    end
    
    def lilypond_note(event, options = {})
      head = Accidentals.translate_note_name(@work, event[:head])
      if options[:head_only]
        head
      else
        if event[:accidental_flag] =~ /\^/
          accidental_flag = event[:accidental_flag].gsub('^', '')
          prefix = '\ficta '
        else
          accidental_flag = event[:accidental_flag]
          prefix = ''
        end
        
        [
          prefix,
          head,
          event[:octave],
          accidental_flag,
          options[:value],
          lilypond_phrasing(event),
          event[:expressions] ? event[:expressions].join : '',
          options[:no_whitespace] ? '' : ' '
        ].join
      end
    end

    def lilypond_chord(event, notes, options = {})
      [
        '<',
        notes.join(' ').strip, # strip trailing whitespace
        '>',
        options[:value],
        lilypond_phrasing(event),
        event[:expressions] ? event[:expressions].join : '',
      ].join
    end

    def lilypond_phrasing(event)
      phrasing = ''
      if @work['process/open_beam']
        phrasing << '['
        @work['process/open_beam'] = nil
      end
      if @work['process/open_slur']
        phrasing << '('
        @work['process/open_slur'] = nil
      end
      phrasing << ']' if event[:beam_close]
      phrasing << ')' if event[:slur_close]
      phrasing
    end

    def lydown_phrasing_open(event)
      phrasing = ''
      if @work['process/open_beam']
        phrasing << '['
        @work['process/open_beam'] = nil
      end
      if @work['process/open_slur']
        phrasing << '('
        @work['process/open_slur'] = nil
      end
      phrasing
    end

    def lydown_phrasing_close(event)
      phrasing = ''
      phrasing << ']' if event[:beam_close]
      phrasing << ')' if event[:slur_close]
      phrasing
    end

    def add_macro_note(event)
      @work['process/macro_group'] ||= @work['process/duration_macro'].clone
      underscore_count = 0

      lydown_note = "{%d:%d}%s%s%s%s%s%s%s" % [
        event[:line] || 0,
        event[:column] || 0,
        lydown_phrasing_open(event),
        event[:head], event[:octave], event[:accidental_flag],
        lydown_phrasing_close(event),
        event[:figures] ? "<#{event[:figures].join}>" : '',
        event[:expressions] ? event[:expressions].join + ' ' : ''
      ]
      
      # replace place holder and repeaters in macro group with actual note
      @work['process/macro_group'].gsub!(/[_∞]/) do |match|
        case match
        when '_'
          underscore_count += 1
          underscore_count == 1 ? lydown_note : match
        when '∞'
          underscore_count < 2 ? event[:head] : match
        end
      end

      # keep filename and source in order to ensure source references are kept
      # correct
      @work['process/macro_filename'] = event[:filename]
      @work['process/macro_source'] = event[:source]

      # if group is complete, compile it just like regular code
      unless @work['process/macro_group'].include?('_')
        Notes.add_duration_macro_group(@work, @work['process/macro_group'])
      end
    end
    
    # emits the current macro group up to the first placeholder character.
    # this method is called 
    def self.cleanup_duration_macro(work)
      return unless work['process/macro_group']
      
      # truncate macro group up until first placeholder
      group = work['process/macro_group'].sub(/_.*$/, '')
      add_duration_macro_group(work, group)
    end
    
    def self.add_duration_macro_group(work, group)
      opts = (work[:options] || {}).merge({
        filename: work['process/macro_filename'],
        source:   work['process/macro_source']
      }).deep!
      code = LydownParser.parse_macro_group(group, opts)

      # stash macro
      macro = work['process/duration_macro']
      work['process/duration_macro'] = nil
      work['process/macro_group'] = nil

      work.process(code, no_reset: true)
    ensure
      # restore macro
      work['process/duration_macro'] = macro
    end
    
    def add_macro_event(code)
      case @work['process/macro_group']
      when nil
        @work['process/macro_group'] = @work['process/duration_macro'].clone
        @work['process/macro_group'].insert(0, " #{code} ")
      when /_/
        @work['process/macro_group'].sub!(/([_∞])/, " #{code} \\0")
      end
    end

    LILYPOND_EXPRESSIONS = {
      '_' => '--',
      '.' => '-.',
      '`' => '-!'
    }

    def translate_expressions
      return unless @event[:expressions]

      @event[:expressions] = @event[:expressions].map do |expr|
        if expr =~ /^(?:\\(_?))?"(.+)"$/
          placement = ($1 == '_') ? '_' : '^'
          "#{placement}\\markup { #{translate_string_expression($2)} }"
        elsif expr =~ /^\\/
          expr
        elsif LILYPOND_EXPRESSIONS[expr]
          LILYPOND_EXPRESSIONS[expr]
        else
          raise LydownError, "Invalid expression #{expr.inspect}"
        end
      end
    end

    def translate_string_expression(expr)
      expr.unescape.
          gsub(/__([^_]+)__/) {|m| "\\bold { #{$1} }" }.
          gsub(/_([^_]+)_/) {|m| "\\italic { #{$1} }" }
    end
    
    TEXTMATE_URL = "txmt://open?url=file://%s&line=%d&column=%d"
    
    ADD_LINK_COMMAND = '\once \override NoteHead.after-line-breaking =
            #(add-link "%s") '
    
    def note_event_url_link(event)
      url = TEXTMATE_URL % [
        File.expand_path(event[:filename]).uri_escape,
        event[:line],
        event[:column]
      ]
      
      ADD_LINK_COMMAND % [url]
    end
  end
end
