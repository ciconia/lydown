require 'treetop'

require 'lydown/parsing/nodes'

Treetop.load './lib/lydown/parsing/lydown'

class LydownParser
  def self.parse(source, opts = {})
    parser = self.new
    ast = parser.parse(source)
    unless ast
      error_msg = format_parser_error(source, parser, opts)
      STDERR.puts error_msg
      raise LydownError, error_msg
    else
      ast.to_stream
    end
  end

  def self.format_parser_error(source, parser, opts)
    msg = opts[:source_filename] ? "#{opts[:source_filename]}: " : ""
    if opts[:nice_error]
      msg << "Unexpected character at line #{parser.failure_line} column #{parser.failure_column}:\n"
    else
      msg << "#{parser.failure_reason}:\n"
    end
    msg << "  #{source.lines[parser.failure_line - 1]} #{' ' * parser.failure_column}^"

    msg
  end
end
