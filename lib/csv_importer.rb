directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, "csv_importer", "support")
require File.join(directory, "csv_importer", "table")
require File.join(directory, "csv_importer", "column")
require File.join(directory, "csv_importer", "columns")
require File.join(directory, "csv_importer", "base")

module CSVImporter
  def import(options = {})
    
    require_files
    errors = []
    options.each do |model, file|
      model = model.capitalize
      eval("errors << #{model}.import(#{model}, #{file.to_s})")
    end

    errors.flatten
  end
  module_function :import
  
  def require_files
    # TODO: Make the directory
    files = Dir[Rails.root.join('app/models/csv_importer/*.rb')]
    files.each{ |f| require f } unless files.empty?
  end
  module_function :require_files
end
