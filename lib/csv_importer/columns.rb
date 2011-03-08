module CSVImporter
  module Columns
    def self.included(base)
      base.class_eval do 
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def columns
        @columns ||= HashWithIndifferentAccess.new
      end
      
      def keys
        @keys ||= []
      end
      
      def column(db_name, sheet_name, type, options = { })
        column = Column.new(db_name, sheet_name, type, options)
        columns[db_name] = column
        keys << db_name
        create_accessors_for(column)
      end
      
      def get_key(model_name, idx)
        keys.each do |key|
          return key if idx == key and @columns[idx].model_name.downcase == model_name.downcase.strip
        end
        return nil
      end
      
      private
      
      def create_accessors_for(column)
        Columns.module_eval <<-end_eval
          def #{column.db_name}
            read_attribute(:'#{column.db_name}')
          end
          
          def #{column.db_name}=(value)
            write_attribute(:'#{column.db_name}', value)
          end
        end_eval
      end
    end
      
    module InstanceMethods
      def [](name)
        read_attribute(name)
      end

      def []=(name, value)
        write_attribute(name, value)
      end
      
      def attributes
        attrs = HashWithIndifferentAccess.new
      
        _columns.each do |key, column|
          attrs[key] = self[key] if column.is_attr
        end

        attrs
      end
      
      def attributes=(record)
        _columns.each do |key, column|
          self[key] = (record.send(key.to_sym) rescue nil)
        end
      end
      
      def values(root_url = nil)
        _keys.inject([]) do |vals, key|
          val = self[key]
          if val.is_a?(TrueClass) || val.is_a?(FalseClass)
            val = val ? 1 : 0
          elsif val.is_a?(Time) || val.is_a?(Date)
            val = val.strftime("%Y%m%d")
          elsif val.is_a?(Array)
            val = val.join(",")
          end
          
          if _columns[key].type == PhotoFile && !val.start_with?("http")
            val = "#{root_url}#{val}"
          end
          
          vals << val
        end
      end

      def valid?
        _columns.each_pair do |key, column|
          value = self[key]
          return false unless column.valid?(value)
        end
        return true
      end
      
      private
      def _columns
        self.class.columns
      end
      
      def _keys
        self.class.keys
      end
      
      def read_attribute(name)
        if column = _columns[name]
          column.get(instance_variable_get("@#{name}"))
        else
          raise ColumnNotFound, "Could not find column: #{name.inspect}"
        end
      end
      
      def write_attribute(name, value)
        column = _columns[name]
        instance_variable_set "@#{name}", column.set(value)
      end
    end
  end
end
