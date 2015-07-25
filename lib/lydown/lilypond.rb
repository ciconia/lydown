require 'lydown/errors'
require 'lydown/cli/output'

require 'tempfile'
require 'fileutils'
require 'open3'

module Lydown
  module Lilypond
    class << self
      def tmpdir
        @tmpdir ||= Dir.mktmpdir
      end
      
      def compile(source, opts = {})
        opts[:output_filename] ||= 'lydown'
        
        target = opts[:output_filename].dup
        ext = ".#{opts[:format] || 'pdf'}"
        if target !~ /#{ext}$/
          target << ext
        end
        
        tmp_target = Tempfile.new('lydown').path
        opts[:output_filename] = tmp_target
        invoke(source, opts)
        
        if File.file?(tmp_target + ext)
          FileUtils.cp(tmp_target + ext, target)
        else
          copy_pages(tmp_target, target, ext)
        end
      rescue => e
        $stderr.puts e.message
        $stderr.puts e.backtrace.join("\n")
        raise e
      end
      
      def copy_pages(source, target, ext)
        page = 1
        loop do
          source_fn = source + "-page#{page}" + ext
          break unless File.file?(source_fn)
          
          target_fn = target.dup.insert(target.index(/\.[^\.]+$/), "-page#{page}")
          
          FileUtils.cp(source_fn, target_fn)
          page += 1
        end
      end
      
      def invoke(source, opts = {})
        # Run lilypond, pipe source into its STDIN, and capture its STDERR
        cmd = 'lilypond '
        cmd << "-o #{opts[:output_filename]} "
        cmd << "-dno-point-and-click "
        cmd << "--#{opts[:format]} " if opts[:format]
        cmd << ' - '
        
        err_info = ''
        success = false
        Open3.popen2e(cmd) do |input, output, wait_thr|
          input.puts source
          input.close_write
          err_info = read_lilypond_progress(output, opts)
          output.close
          success = wait_thr.value == 0
        end
        unless success
          err_info = err_info.lines[0, 3].join
          raise LydownError, "Lilypond compilation failed:\n#{err_info}"
        end
      end
      
      LILYPOND_STATUS_LINES = %w{
        Processing
        Parsing
        Interpreting
        Preprocessing
        Finding
        Fitting
        Drawing
        Layout
        Converting
        Success:
      }
      STATUS_TOTAL = LILYPOND_STATUS_LINES.size
      
      def read_lilypond_progress(f, opts)
        info = ''
        Lydown::CLI::show_progress('Compile', STATUS_TOTAL) do |bar|
          while !f.eof?
            line = f.gets
            info += line
            if line =~ /^([^\s]+)/
              idx = LILYPOND_STATUS_LINES.index($1)
              bar.progress = idx + 1 if idx
            end
          end
        end
        info
      end
    end
  end
end

