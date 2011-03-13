module CSVImporter
  class Base
    @@primary_keys_mapping ||= {}
    
    include Columns

    def self.import(model, file_path)
      model = model.capitalize
      table = Table.new(file_path)
      errors = []
      table.rows.each do |rownum, row|
        begin
          base = new
          
          row.to_hash.each do |idx, col_val|
            # col_val = col_val.to_i if col_val.is_a? Numeric
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
      errors
    end

    def self.primary_keys_mapping
      return @@primary_keys_mapping
    end

    def save(model)
      db_record = save_to_database(model)
      if has_primary_key?
        primary_key_column = self.get_primary_column
        @@primary_keys_mapping[model] ||= {}
        @@primary_keys_mapping[model][self[primary_key_column.db_name]] = db_record.send(primary_key_column.db_name)
        puts "Hash: #{@@primary_keys_mapping.inspect}"
      end
    end

    def save_to_database(model)
      db_model = eval("ActiveRecord::Base::#{model}")
      if self.valid?
         model_instance = db_model.new
         self.attributes.each do |key, value|
           model_instance.send("#{key}=".to_sym, value) unless eval("#{model}.columns[key].primary_key")
       end
         return model_instance if model_instance.save
      end
    end

  end 
end
