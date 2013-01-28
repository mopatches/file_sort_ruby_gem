class LargeFileGenerator

  DEFAULTS = {
      num_columns:        10,
      num_rows:           1e6.to_i,
      column_separator:   "\t"
  }

  def initialize(filename, options = {})
    @filename = filename
    @options = DEFAULTS.merge(options)
  end

  def generate!
    File.open(@filename, "w") do |f|
      @options[:num_rows].times do
        f.puts (0...@options[:num_columns]).map{rand(@options[:num_rows])}.join(@options[:column_separator])
      end
    end
  end
end

#Run as
#LargeFileGenerator.new("large-file-1000000.csv", { num_rows: 1000000 }).generate!