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

    f1_line = self.get_line(f1)
    f2_line = self.get_line(f2)
    while !f1_line.nil? and !f2_line.nil?
      if f1_line[@sort_column] < f2_line[@sort_column]
        self.write_line(outfile, f1_line)
        f1_line = self.get_line(f1)
      else
        self.write_line(outfile, f2_line)
        f2_line = self.get_line(f2)
      end
    end

    while !f1_line.nil?
      self.write_line(outfile, f1_line)
      f1_line = self.get_line(f1)
    end

    while !f2_line.nil?
      self.write_line(outfile, f2_line)
      f2_line = self.get_line(f2)
    end


    f1.close
    f2.close
    outfile.close
  end

  def get_line(stream)
    line = stream.gets
    return nil if line.nil?
    line = line.chomp.split(@column_separator)
    line[@sort_column] = line[@sort_column].to_i if @sort_as_int
    return line
  end

  def write_line(stream, line)
    stream.puts line.join(@column_separator)
  end
end

Merger.new.merge!