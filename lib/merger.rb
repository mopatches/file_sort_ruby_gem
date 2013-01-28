class Merger
  def initialize
    @filename1          = ENV["filename1"]
    @filename2          = ENV["filename2"]
    @output_filename    = ENV["output_filename"]
    @sort_column        = ENV["sort_column"].to_i
    @sort_as_int        = ENV["sort_as_int"] == "true"
    @column_separator   = ENV["column_separator"]
  end

  def merge!
    outfile = File.open(@output_filename, "w")
    f1 = File.open(@filename1)
    f2 = File.open(@filename2)

    f1_line, f1_col = self.get_line(f1)
    f2_line, f2_col = self.get_line(f2)
    while !f1_line.nil? and !f2_line.nil?
      if f1_col < f2_col
        outfile.print f1_line
        f1_line, f1_col = self.get_line(f1)
      else
        outfile.print f2_line
        f2_line, f2_col = self.get_line(f2)
      end
    end

    while !f1_line.nil?
      outfile.print f1_line
      f1_line, f1_col = self.get_line(f1, false)
    end

    while !f2_line.nil?
      outfile.print f2_line
      f2_line, f2_col = self.get_line(f2, false)
    end

    f1.close
    f2.close
    outfile.close
  end

  def get_line(stream, parse_cols = true)
    line = stream.gets
    return [nil, nil] if line.nil?
    return [line, nil] unless parse_cols
    cols = line.chomp.split(@column_separator, @sort_column + 2)
    cols[@sort_column] = cols[@sort_column].to_i if @sort_as_int
    return [line, cols[@sort_column]]
  end

end

Merger.new.merge!