module Crudable
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def creatable?(creator, parent = nil)
        raise "Did not overridden method '#{self}.createble?'"
      end

      def readable?(reader, parent = nil)
        raise "Did not overridden method '#{self}.readable?'"
      end
    end

    def readable?(reader)
      raise "Did not overridden method '#{self.class}#readable?'"
    end

    def updatable?(updater)
      raise "Did not overridden method '#{self.class}#updatable?'"
    end

    def deletable?(deleter)
      raise "Did not overridden method '#{self.class}#deletable?'"
    end
  end
end
