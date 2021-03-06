require 'escape_utils'
require 'pathname'

class Hash
  # Merges self with another hash, recursively.
  #
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  #
  # Thanks to whoever made it.
  def deep_merge(hash)
    target = Marshal.load(Marshal.dump(self))
    target.deep_merge!(hash)
  end

  def deep_merge!(hash)
    unless self.hash == hash.hash
      hash.each do |key, value|
        svalue = self.old_get(key)
      
        if (value.is_a? Hash) && (svalue.is_a? Hash)
          old_set(key, svalue.deep_merge(value))
        else
          old_set(key, value)
        end
      end
    end

    self.deep = true
    self
  end
  
  def deep_clone
    dest = {}.deep!
    each do |k, v|
      dest[k] = case v
      when Hash
        v.deep_clone
      when Array
        v.clone
      else
        v
      end
    end
    dest
  end

  def lookup(path)
    path.split("/").inject(self) {|m,i| m[i].nil? ? (return nil) : m[i]}
  end
  
  def set(path, value)
    leafs = path.split("/")
    k = leafs.pop
    h = leafs.inject(self) {|m, i| m[i].is_a?(Hash) ? m[i] : (m[i] = {})}
    h[k] = value
  end
  
  attr_accessor :deep

  alias_method :old_get, :[]
  def [](k)
    if @deep && k.is_a?(String) && k =~ /\//
      lookup(k)
    elsif @deep && k.is_a?(Symbol)
      old_get(k) || old_get(k.to_s)      
    else
      old_get(k)
    end
  end
  
  alias_method :old_set, :[]=
  def []=(k, v)
    if @deep && k.is_a?(String) && k =~ /\//
      set(k, v)
    elsif @deep && k.is_a?(Symbol)
      old_set(k.to_s, v)
    else
      old_set(k, v)
    end
  end
  
  alias_method :old_merge, :merge
  def merge(hash)
    if @deep || hash.deep
      deep_merge(hash)
    else
      old_merge(hash)
    end
  end
  
  alias_method :old_merge!, :merge!
  def merge!(hash)
    if @deep || hash.deep
      deep_merge!(hash)
    else
      old_merge!(hash)
    end
  end
  
  def deep!
    @deep = true
    self
  end
  
  def is_deep?
    !!@deep
  end
  
  def stringify_keys
    h = {}
    each {|k, v| h[k.to_s] = v}
    h
  end
end

class String
  def titlize(all_capitals = false)
    all_capitals ? 
      self.gsub("-", " ").gsub(/\b('?[a-z])/) {$1.capitalize} :
      self.gsub("-", " ").capitalize
  end

  def camelize
    split('_').collect(&:capitalize).join
  end
  
  # String unescaping code from here: http://stackoverflow.com/a/20131717

  UNESCAPES = {
      'a' => "\x07", 'b' => "\x08", 't' => "\x09",
      'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
      'r' => "\x0d", 'e' => "\x1b", "\\\\" => "\x5c",
      "\"" => "\x22", "'" => "\x27"
  }

  def unescape
    # Escape all the things
    gsub(/\\(?:([#{UNESCAPES.keys.join}])|u([\da-fA-F]{4}))|\\0?x([\da-fA-F]{2})/) {
      if $1
        if $1 == '\\' then '\\' else UNESCAPES[$1] end
      elsif $2 # escape \u0000 unicode
        ["#$2".hex].pack('U*')
      elsif $3 # escape \0xff or \xff
        [$3].pack('H2')
      end
    }
  end
  
  def calculate_line_indexes
    i = -1
    indexes = {0 => 0}
    line = 1
    while i = index("\n", i + 1)
      indexes[line] = i + 1 # first character after line break
      line += 1
    end
    indexes
  end
  
  def find_line_and_column(index)
    @line_indexes ||= calculate_line_indexes
    line = @line_indexes.reverse_each {|l, i| break l if i <= index}
    
    # return line and column
    if line.nil?
      [nil, nil]
    else
      [(line + 1), (index - @line_indexes[line] + 1)]
    end
  end
  
  def uri_escape
    EscapeUtils.escape_uri(self)
  end
end

class Fixnum
  # Taken from https://github.com/AndrewVos/roman-numerals
  # Copyright (c) 2011 Andrew Vos
  @@roman_digits = {
    1000 => 'M',
    900  => 'CM',
    500  => 'D',
    400  => 'CD',
    100  => 'C',
    90   => 'XC',
    50   => 'L',
    40   => 'XL',
    10   => 'X',
    9    => 'IX',
    5    => 'V',
    4    => 'IV',
    1    => 'I'
  }

  def to_roman
    result = ''
    value = self
    @@roman_digits.keys.each do |decimal|
      while value >= decimal
        value -= decimal
        result += @@roman_digits[decimal]
      end
    end
    result
  end
end

class Pathname
  # Returns path relative to working directory
  def self.relative_pwd(path)
    self.new(path).relative_path_from(pwd).to_s
  end
end

unless Binding.method_defined?(:local_variable_set)
  class Binding
    def local_variable_set(var, value)
      eval("#{var.to_s} = #{value.inspect}")
    end
  end
end
