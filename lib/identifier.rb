module Identifier
  def self.included(base)
    base.send(:extend, ClassMethods)
  end
  
  module ClassMethods
    def has_identifier(column, &block)
      cattr_accessor :col, :generator
      self.col, self.generator = column, block
      send(:attr_protected, column)
      send(:before_save, :generate_identifier)
      send(:include, InstanceMethods)
    end
  end
  
  module InstanceMethods
    def generate_identifier
      col = send(self.class.col)
      if col.nil?
        @identifier = self.class.generator.call(self)
        if self.class.first(:conditions => {self.class.col => @identifier})
          generate_identifier
        else
          self[self.class.col] = @identifier
        end
      end
    end
  end
end