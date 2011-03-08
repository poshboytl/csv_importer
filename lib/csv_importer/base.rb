module CSVImporter
  class Base
    @@primary_keys_mapping ||= {}
    
    include Columns

    def self.import(model_name, file_path)
      model_name = model_name.capitalize
      table = Table.new(file_path)
      errors = []
      table.rows.each do |rownum, row|
        begin
          base = new
          
          row.to_hash.each do |idx, col_val|
            # col_val = col_val.to_i if col_val.is_a? Numeric
            if key = get_key(model_name, idx)
              base[key] = col_val
            end
          end
          base.save_to_database(account)
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

    def save_to_database(model_name)
      model = eval("ActiveRecord::Base::#{model_name}")
      if self.valid?
        model.new
        self.attributes.each do |key, value|
          model.send("#{key}=".to_sym, value)
      end
        
      end
    end
  end 
end
