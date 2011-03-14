module CSVImporter
  class Base
    @@primary_keys_mapping ||= {}
    
    include Columns

    def self.import(model, file_path)
      model = model.capitalize
      if has_foreign_key?
        foreign_key_columns = self.get_foreign_keys
        foreign_key_columns.each do |c|
          unless foreign_key_ready?(c)
            Base.jobs.move_first_element_last!
            return
          end
        end
      end
      table = Table.new(file_path)
      errors = []
      
      table.rows.each do |rownum, row|
        begin
          base = new
          
          row.to_hash.each do |idx, col_val|
            if key = get_key(idx)
              base[key] = col_val
            end
          end
          base.save(model)
        rescue ActiveRecord::RecordInvalid => invalid
          errors << "File #{name.demodulize} - Row #{rownum} fails: #{invalid.record.errors.full_messages.join(", ")}"
        rescue Exception => e
          errors << "File #{name.demodulize} - Row #{rownum} fails: #{e.message}"
        ensure
          rownum += 1
        end
      end
      Base.jobs.delete_at(0)
      errors
    end

    def self.primary_keys_mapping
      return @@primary_keys_mapping
    end
    
    def self.jobs
      return @@jobs ||= []
    end
    
    def self.jobs=(value)
      @@jobs = value if value.is_a?(Array)
    end
    
    def self.foreign_key_ready?(column)
      return true if @@primary_keys_mapping.has_key?(column.foreign_key)
      return false
    end

    def save(model)
      db_record = save_to_database(model)
      if has_primary_key?
        primary_key_column = self.get_primary_column
        @@primary_keys_mapping[model] ||= {}
        @@primary_keys_mapping[model][self[primary_key_column.db_name].to_s] = db_record.send(primary_key_column.db_name)
        puts "Hash: #{@@primary_keys_mapping.inspect}"
      end
    end

    def save_to_database(model)
      db_model = eval("ActiveRecord::Base::#{model}")
      if self.valid?
         model_instance = db_model.new
         self.attributes.each do |key, value|
           db_value = value
           eval <<-end_eval
             if !!#{model}.columns[key].foreign_key
               foreign_key_value = #{model}.columns[key].foreign_key
               if @@primary_keys_mapping.has_key?(foreign_key_value)
                 db_value = Base.primary_keys_mapping[foreign_key_value]["#{value.to_i}"]
               end
             end
           end_eval
           model_instance.send("#{key}=".to_sym, db_value) unless eval("#{model}.columns[key].primary_key")
       end
         if model_instance.save
           return model_instance 
         end
      end
    end

  end 
end
