module Lydown::Rendering
  module Movement
    def self.movement_title(work, name)
      return nil if name.nil? || name.empty?
      
      if name =~ /^(?:([0-9])+([a-z]*))\-(.+)$/
        title = "#{$1.to_i}#{$2}. #{$3.capitalize}"
      else
        title = name
      end
      
      if work["movements/#{name}/parts"].empty?
        title += " - tacet"
      end
      
      title
    end
  end
end