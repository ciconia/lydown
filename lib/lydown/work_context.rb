module Lydown
  # A WorkContext instance holds the entire state of a work being processed.
  # This includes both the document settings and processing state, and the
  # resulting lilypond streams and associated data.
  class WorkContext
    attr_reader :context
    
    include TemplateBinding
    
    def initialize(opts = {}, context = nil)
      if context
        @context = context
      else
        @context = {}.deep!
        reset(:work)
        @context[:options] = opts.deep_clone
      end
    end
    
    # process lydown stream by translating into self
    def translate(stream, opts = {})
      stream.each_with_index do |e, idx|
        if e[:type]
          Lydown::Rendering.translate(self, e, stream, idx)
        else
          raise LydownError, "Invalid lydown stream event: #{e.inspect}"
        end
      end
      reset(:part) unless opts[:macro_group]
    end

    def reset(mode)
      case mode
      when :work
        @context[:part] = nil
        set_setting(:time, '4/4')
        set_setting(:tempo, nil)
        @context[:cadenza_mode] = nil
        set_setting(:key, 'c major')
        set_setting(:pickup, nil)
        set_setting(:beaming, nil)
        set_setting(:end_barline, nil)
      when :movement
        @context[:part] = nil
      end
      if @context['process/tuplet_mode']
        Lydown::Rendering::TupletDuration.emit_tuplet_end(self)
      end
      if @context['process/grace_mode']
        Lydown::Rendering::Grace.emit_grace_end(self)
      end
      
      if @context['process/voice_selector']
        Lydown::Rendering::VoiceSelect.render_voices(self)
      end
      
      Lydown::Rendering::Notes.cleanup_duration_macro(self)

      # reset processing variables
      @context['process'] = {
        'duration_values' => ['4'],
        'running_values' => []
      }
    end

    def clone_for_translation
      new_context = @context.deep_merge({'movements' => nil})
      WorkContext.new(nil, new_context)
    end
    
    def merge_movements(ctx)
      return unless ctx['movements']
      if @context['movements']
        @context['movements'].deep_merge! ctx['movements']
      else
        @context['movements'] = ctx['movements']
      end
    end
    
    def filter(opts = {})
      filtered = @context.deep_clone

      if filtered[:movements].nil? || filtered[:movements].size == 0
        # no movements found, so no music
        raise LydownError, "No music found"
      elsif filtered[:movements].size > 1
        # delete default movement if other movements are present
        filtered[:movements].delete('')
      end

      if filter = opts[:movements]
        filter = [filter] unless filter.is_a?(Array)
        filtered[:movements].select! {|name, m| filter.include?(name.to_s)}
      end

      if filter = opts[:parts]
        filter = [filter] unless filter.is_a?(Array)
        filter += opts[:include_parts] if opts[:include_parts]
      end
      
      filtered[:movements].each do |movement_name, m|
        # delete default part if other parts are present
        if m[:parts].size > 1
          m[:parts].delete('')
        end

        filter_movement_parts(movement_name, m, filter)
      end

      WorkContext.new(nil, filtered)
    end
    
    DEFAULT_SOURCE_STREAMS = %w{music}
    
    # Parts are filtered as follows:
    # 
    # - Parts for which the render_modes do not include the current mode
    #   are rejected.
    # - If a filter is provided, only the specified parts are selected, and any
    #   colla parte parts are added if found.
    # - Part includes are checked and added as well
    def filter_movement_parts(movement_name, m, filter)
      mode = self['options/mode']
      if DEFAULT_RENDER_MODES.include?(mode)
        m[:parts].select!  do |part_name|
          part_render_modes(movement_name, part_name).include?(mode)
        end
      end
      
      select_filter_parts(movement_name, m, filter) if filter
      add_part_includes(movement_name, m)
    end

    DEFAULT_RENDER_MODES = [:part, :score]
    
    def part_render_modes(movement_name, part_name)
      modes = get_setting(:render_modes, part: part_name, movement: movement_name)
      if modes
        modes.split(',').map {|m| m.strip.to_sym}
      else
        DEFAULT_RENDER_MODES
      end
    end
    
    def select_filter_parts(movement_name, m, filter)
      m[:parts].select! {|part_name, p| filter.include?(part_name)}
    
      # go over filter and check for colla parte
      filter.each do |part_name|
        unless m[:parts].keys.include?(part_name)
          if source = part_source(movement_name, part_name)
            part_path = "parts/#{part_name}"
            source_path = "movements/#{movement_name}/parts/#{source}"
          
            source_streams = ['settings']
            if stream_list = part_source_streams(movement_name, part_name)
              source_streams += stream_list.split(',').map(&:strip)
            else
              source_streams += DEFAULT_SOURCE_STREAMS
            end
          
            m[part_path] = source_streams.inject({}) do |hash, stream|
              hash[stream] = self["#{source_path}/#{stream}"]
              hash
            end.deep!
          end
        end
      end
    end
    
    def add_part_includes(movement_name, m)
      # check for part includes
      if part = self['options/parts']
        part = part[0] if part.is_a?(Array)
        includes = get_setting(:include_parts, 
          movement: movement_name, part: part)
          
        return unless includes
        
        includes = includes.split(',').map(&:strip)
        
        includes.each do |included_part|
          # If the included part does not exist, try to find its source
          part_hash = self["movements/#{movement_name}/parts/#{included_part}"]
          unless part_hash
            source = part_source(movement_name, included_part)
            part_hash = self["movements/#{movement_name}/parts/#{source}"]
          end
          m["parts/#{included_part}"] ||= part_hash
        end
      end
    end
    
    def [](key)
      @context[key]
    end
    
    def []=(key, value)
      @context[key] = value
    end
    
    def emit(path, *content)
      if self['process/mode']
        return unless self['process/mode'] == render_mode
      end
      
      stream = current_stream(path)

      content.each {|c| stream << c}
    end

    def current_stream(subpath)
      if @context['process/voice_selector']
        path = "process/voices/#{@context['process/voice_selector']}/#{subpath}"
      else
        movement = @context[:movement]
        part = @context[:part]
        path = "movements/#{movement}/parts/#{part}/#{subpath}"
      end
      @context[path] ||= (subpath == :settings) ? {} : ''
    end
    
    def set_part_context(part)
      movement = @context[:movement]
      path = "movements/#{movement}/parts/#{part}/settings"

      settings = {}.deep!
      settings[:pickup] = @context[:pickup]
      settings[:key] = @context[:key]
      settings[:tempo] = @context[:tempo]
      
      @context[path] = settings
    end
    
    def settings_path(movement, part)
      if part
        "movements/#{movement}/parts/#{part}/settings"
      elsif movement && !movement.empty?
        "movements/#{movement}/settings"
      else
        "global/settings"
      end
    end
    
    def query_setting(movement, part, path)
      path = "#{settings_path(movement, part)}/#{path}"
      value = @context[path]

      unless value.nil?
        @temp_setting_value = value
        true
      else
        false
      end
    end
    
    def rendered_edition
      @rendered_edition = @context['render_opts/edition']
    end
    
    def query_defaults(path)
      value = DEFAULTS[path]
      unless value.nil?
        @temp_setting_value = value
        true
      else
        false
      end
    end
    
    def query_setting_tree(movement, part, path)
      path = "#{settings_path(movement, part)}/#{path}"
      @context[path] || {}
    end
    
    def get_setting(path, opts = {})
      # In order to allow false values for settings, we create
      # a temporary instance variable, and use it to store the
      # setting value once it's found. That way we can use the
      # || operator to stop searching once we've found it.
      @temp_setting_value = nil
      
      if opts[:part]
        parts_section_path = "parts/#{opts[:part]}/#{path}"
        
        query_setting(opts[:movement], opts[:part], path) ||
        query_setting(nil, opts[:part], path) ||
        
        # search in parts section
        query_setting(opts[:movement], nil, parts_section_path) ||
        query_setting(opts[:movement], nil, path) ||

        query_setting(nil, nil, parts_section_path) ||

        query_setting(nil, nil, path) ||
        
        query_defaults("parts/#{opts[:part]}/#{path}") ||
        query_defaults(path)
      else
        query_setting(opts[:movement], nil, path) || 
        query_setting(nil, nil, path) || 
        query_defaults(path)
      end
      @temp_setting_value
    end
    
    # Get setting while code is being translated
    def get_current_setting(path)
      get_setting(path, current_setting_opts)
    end
    
    def current_setting_opts
      {movement: @context[:movement], part: @context[:part]}
    end
    
    # Returns a merged tree of the settings from different levels
    def get_merged_setting_tree(path, opts)
      tree = (DEFAULTS[path] || {}).deep_merge(
              query_setting_tree(nil, nil, path))

      if opts[:movement]
        tree.deep_merge! query_setting_tree(opts[:movement], nil, path)
      else
        tree.deep!
      end
    end
    
    def colla_parte_map(movement_name)
      parts_settings = get_merged_setting_tree(:parts, movement: movement_name)
      colla_parte = get_merged_setting_tree(:colla_parte, movement: movement_name)
      
      map = Hash.new {|h, k| h[k] = []}
      parts_settings.each do |name, settings|
        if source = settings['source']
          map[source] << name
        end
      end
      
      colla_parte.each do |source, parts|
        parts.split(',').map(&:strip).inject(map[source]) do |m, p|
          m << p unless m.include?(p); m
        end
      end
      
      map
    end
    
    def part_source(movement_name, part_name)
      parts_settings = get_merged_setting_tree(:parts, movement: movement_name)
      if source = parts_settings["#{part_name}/source"]
        return source
      else
        colla_parte = get_merged_setting_tree(:colla_parte, movement: movement_name)
        colla_parte.each do |source, parts|
          if parts.split(',').map(&:strip).include?(part_name)
            return source
          end
        end
      end 
      nil
    end
    
    def part_source_streams(movement_name, part_name)
      parts_settings = get_merged_setting_tree(:parts, movement: movement_name)
      parts_settings["#{part_name}/source_streams"]
    end

    def set_setting(path, value)
      path = "#{settings_path(@context[:movement], @context[:part])}/#{path}"
      @context[path] = value
    end
    
    def render_mode
      self['options/mode'] || self['render_opts/mode']
    end
    
    # Returns a list of parts to extract for the specified opts. Only parts
    # that should be extracted (based on the render_modes setting) are included.
    def part_list_for_extraction(opts)
      parts = []
      return parts unless @context[:movements]
      
      @context[:movements].each do |mname, m|
        if m[:parts]
          m[:parts].each do |pname, p|
            # Add only parts that render in part mode
            if part_render_modes(mname, pname).include?(:part)
              parts << pname unless (pname == '') || parts.include?(pname)
            end
          end
        end
      end
      parts
    end
  end
end
