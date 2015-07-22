require 'thor'

module Lydown::CLI
  class Commands < Thor
    desc "version", "show Lydown version"
    def version
      require 'lydown/version'
      
      puts "Lydown version #{Lydown::VERSION}"
      exit!(0)
    end

    desc "compile [PATH]", "compile the lydown source at PATH"
    method_option :format, aliases: '-f', 
      default: 'pdf', desc: 'Set output format (pdf/png/ly)', 
      enum: %w{pdf png ly}
    method_option :png, desc: 'Set output format as PNG'
    method_option :parts, aliases: '-p',
      desc: 'Compile only the specified parts (comma separated)'
    method_option :movements, aliases: '-m',
      desc: 'Compile only the specified movements (comma separated)'
    method_option :score_only, aliases: '-s',
      desc: 'Compile score only'
    method_option :parts_only, aliases: '-n',
      desc: 'Compile parts only'
    method_option :output, aliases: '-o',
      desc: 'Set output path'
    method_option :open_target, aliases: '-O',
      desc: 'Open output file after compilation'
    def compile(*args)
      require 'lydown'
      
      opts = Lydown::CLI::Support.copy_options(options)
      opts[:path] = args.first || '.'
      Lydown::CLI::Support.detect_filename(opts)
      
      # Set format based on direct flag
      [:png].each {|f| opts[:format] = f if opts[f]}

      opts[:parts] = opts[:parts].split(',') if opts[:parts]
      opts[:movements] = opts[:movements].split(',') if opts[:movements]
      
      # compile score
      unless opts[:parts_only] || opts[:parts]
        Lydown::CLI::Compiler.process(opts.merge(mode: :score, parts: nil))
      end

      # compile parts
      unless opts[:score_only] || !opts[:parts]
        parts = opts[:parts]
        parts.each do |p|
          Lydown::CLI::Compiler.process(opts.merge(mode: :part, parts: p))
        end
      end
    end
  
    desc "proof [PATH]", "start proofing mode on source at PATH"
    method_option :format, aliases: '-f', 
      default: 'pdf', desc: 'Set output format (pdf/png/ly)', 
      enum: %w{pdf png ly}
    def proof(*args)
      require 'lydown'

      opts = Lydown::CLI::Support.copy_options(options)
      opts[:path] = args.first || '.'
      opts[:proof_mode] = true
      opts[:open_target] = true
    
      Lydown::CLI::Support.detect_filename(opts)
      Lydown::CLI::Proofing.start_proofing(opts)
    end
    
    desc "translate [PATH]", "translate source at PATH into lydown code"
    def translate(*args)
      require 'lydown'

      opts = Lydown::CLI::Support.copy_options(options)
      opts[:path] = args.first || '.'
    
      Lydown::CLI::Translation.process(opts)
    end
    
    def method_missing(method, *args)
      args = ["compile", method.to_s] + args
      self.class.start(args)
    end
  
    default_task :compile

    # Allow default task with test as path (should we be doing this for other 
    # Object instance methods?)
    undef_method(:test)
  end
end