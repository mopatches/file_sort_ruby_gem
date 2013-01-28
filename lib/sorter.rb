class Sorter

  def initialize
    @input_filename     = ENV["input_filename"]
    @sorted_filename    = ENV["sorted_filename"]
    @sort_column        = ENV["sort_column"].to_i
    @sort_as_int        = ENV["sort_as_int"] == "true"
    @column_separator   = ENV["column_separator"]
  end

  def sort!
    lines = []
    infile = File.open(@input_filename)
    while line = infile.gets
      line = line.chomp.split(@column_separator)
      line[@sort_column] = line[@sort_column].to_i if @sort_as_int
      lines << line
    end
    infile.close
    lines.sort!{ |a, b| a[@sort_column] <=> b[@sort_column] }
    outfile = File.open(@sorted_filename, "w")
    lines.each{ |line| outfile.puts(line.join(@column_separator)) }
    outfile.close
  end
end

Sorter.new.sort!