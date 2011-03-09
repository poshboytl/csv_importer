module CSVImporter
  class Table
    require 'fastercsv'
    attr_accessor :heards, :rows

    def initialize(file_path)
      row_num = 0
      @rows = {}
      FasterCSV.foreach(file_path) do |row|

        row_num += 1
        if row_num == 1
          @heards = row
        else
          @rows[row_num] = FasterCSV::Row.new(@heards, row)
        end
      end
    end

  end
end