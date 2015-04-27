module Lydown::Parsing
  SETTING_KEYS = [
    'key', 'time', 'pickup', 'clef', 'part', 'movement',
    'accidentals'
  ]
  
  module SettingKeyNode
    def compile(opus)
      if SETTING_KEYS.include?(text_value)
        opus['parser/setting_key'] = text_value
      end
    end
  end
  
  module SettingValueNode
    def compile(opus)
      key = opus['parser/setting_key']
      value = text_value.strip
      return unless key

      emit_setting(opus, key, value)
      opus['parser/setting_key'] = nil
      
    end
    
    RENDERABLE_SETTING_KEYS = [
      'key', 'time', 'clef'
    ]
    
    def emit_setting(opus, key, value)
      opus[key] = check_setting_value(opus, key, value)
      if RENDERABLE_SETTING_KEYS.include?(key)
        value = transform_value(opus, key, value)
        opus.emit(:music, "\\#{key} #{value} ")
      end
    end
    
    ALLOWED_SETTING_VALUES = {
      'accidentals' => ['manual', 'auto']
    }
    
    def check_setting_value(opus, key, value)
      if ALLOWED_SETTING_VALUES[key]
        unless ALLOWED_SETTING_VALUES[key].include?(value)
          raise LydownError, "Invalid value for setting #{key}: #{value.inspect}"
        end
      end
      value
    end
    
    def transform_value(opus, key, value)
      case key
      when 'time'
        value.sub(/[0-9]+$/) { |m| LILYPOND_DURATIONS[m] || m }
      when 'key'
        unless value =~ /^([a-g][\+\-]*) (major|minor)$/
          raise LydownError, "Invalid key signature #{value.inspect}"
        end
        
        key = Lydown::Parsing::Accidentals.lilypond_note_name($1)
        mode = $2
        "#{key} \\#{mode}"
      else
        value
      end
    end
  end
end