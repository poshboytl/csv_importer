module CSVImporter
  class Column
    attr_accessor :db_name, :title_name, :type
    attr_accessor :is_required, :is_uniq, :is_skip_on_fail, :default_value, :primary_key, :foreign_key
    attr_accessor :is_attr
    attr_accessor :value
    
    def initialize(db_name, title_name, type, options = {})
      @db_name = db_name
      @title_name = title_name
      @type = type
      @is_required = options[:is_required] || false
      @is_uniq = options[:is_uniq] || false
      @is_skip_on_fail = options[:is_skip_on_fail] || false
      @is_attr = options.key?(:is_attr) ? options[:is_attr] : true
      @default_value = options.key?(:default) ? options[:default] : nil
      @primary_key = options.key?(:primary_key) ? true : false
      @foreign_key = options.key?(:foreign_key) ? options[:foreign_key] : false
    end
    
    def ==(other)
      @db_name == other.db_name && @model_name == other.model_name
    end
    
    def get(value)
      if value.nil? && !default_value.nil?
        return default_value
      end
      
      type.from_db(value)
    end

    def set(value)
      type.to_db(value)
    end
    
    def valid?(value)
      return false if is_required && value.blank?
      # TODO: check unique
      true
    end
  end
end
