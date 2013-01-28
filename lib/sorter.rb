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
      col = line.split(@column_separator, @sort_column + 2)[@sort_column]
      col = col.to_i if @sort_as_int
      lines << [col, line]
    end
    infile.close
    lines.sort!{ |a, b| a[0] <=> b[0] }
    outfile = File.open(@sorted_filename, "w")
    lines.each{ |line| outfile.print line[1] }
    outfile.close
  end
end

Sorter.new.sort!