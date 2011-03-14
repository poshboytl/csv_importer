directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, "csv_importer", "support")
require File.join(directory, "csv_importer", "table")
require File.join(directory, "csv_importer", "column")
require File.join(directory, "csv_importer", "columns")
require File.join(directory, "csv_importer", "base")

module CSVImporter
  def import(jobs = [])
    Base.jobs = jobs
    require_files
    errors = []
    # To downward compatible with the ruby 1.8. We need make jobs as a Array here. Cause the Hash is no order in ruby 1.8.
    last_time_array_size = 0
    begin
      last_time_array_size = Base.jobs.size
      Base.jobs.first.each do |model, file|
        model = model.capitalize
        eval <<-end_eval
          errors << CSVImporter::#{model.to_s}.import('#{model}', '#{file}')
        end_eval
      end
    end while not Base.jobs.empty?

    errors.flatten
  end
  module_function :import
  
  def require_files
    # TODO: Make the directory configurable.
    files = Dir[Rails.root.join('app/models/csv_importer/*.rb')]
    files.each{ |f| require f } unless files.empty?
  end
  module_function :require_files
end
