class FileSort

  DEFAULTS = {
      sort_column:        0,
      column_separator:   ",",
      num_processes:      3,
      parse_as:           :int, #other options: :string
      lines_per_split:    1e6,
      replace_original:   true,
      log_output:         true
    }

  def initialize(filename, options = {})
    @filename = filename
    raise "File '#{@filename}' doesn't exist." unless File.exists?(@filename)
    @options = DEFAULTS.merge(options)
    @options[:lines_per_split] = @options[:lines_per_split].to_i

    @file_id_counter = 0
    @files_to_sort = []
    @files_to_merge = []
    @active_workers = 0
    @start_time = nil
    @scheduler_thread = nil
  end

  def sort!
    @start_time = Time.now
    self.log("Sorting #{@filename} with up to #{@options[:num_processes]} processes.")
    self.make_splits
    @scheduler_thread = Thread.new do
      while true
        break if @active_workers == 0 and @files_to_sort.empty? and @files_to_merge.size == 1
        if @active_workers < @options[:num_processes]
          unless @files_to_sort.empty?
            self.sort_split(@files_to_sort.shift)
            next
          end
          unless @files_to_merge.size < 2
            self.merge_splits(@files_to_merge.shift, @files_to_merge.shift, self.next_filename)
            next
          end
          sleep
        else
          sleep
        end
      end
    end
    @scheduler_thread.join
    final_name = "#{@filename}.sorted"
    File.rename(@files_to_merge.first, final_name)
    if @options[:replace_original]
      File.delete(@filename)
      File.rename(final_name, @filename)
    end
    self.log("#{@filename} sort complete.")
  end

  def make_splits
    self.log("Splitting #{@filename} every #{@options[:lines_per_split]} lines")
    self.worker_begin
    Thread.new do
      line_counter = 0
      infile = File.open(@filename)
      output_filename = self.next_filename
      outfile = File.open(output_filename, "w")
      while line = infile.gets
        if line_counter >= @options[:lines_per_split]
          outfile.close
          self.log("Split written: #{fid output_filename}")
          @files_to_sort << output_filename
          output_filename = self.next_filename
          outfile = File.open(output_filename, "w")
          line_counter = 0
          @scheduler_thread.wakeup
        end
        outfile.print(line)
        line_counter += 1
      end
      infile.close
      outfile.close
      self.log("Split written: #{fid output_filename} (final split)")
      @files_to_sort << output_filename
      self.worker_done
    end
  end

  def sort_split(filename)
    sorted_filename = self.next_filename
    self.log("Sorting #{fid filename} as #{fid sorted_filename}")
    self.worker_begin
    Thread.new do

      pid = Process.spawn({
          "input_filename"    => filename,
          "sorted_filename"   => sorted_filename,
          "sort_column"       => @options[:sort_column].to_s,
          "sort_as_int"       => (@options[:parse_as] == :int ? "true" : "false"),
          "column_separator"  => @options[:column_separator]
        }, "ruby #{File.join(File.dirname(__FILE__), 'sorter.rb')}")
      Process.waitpid(pid)
      File.delete(filename)
      self.log("Sort complete for #{fid filename} as #{fid sorted_filename}")
      @files_to_merge << sorted_filename
      self.worker_done
    end
  end

  def merge_splits(filename1, filename2, output_filename)
    self.log("Merging (#{fid filename1}, #{fid filename2}) => #{fid output_filename}")
    self.worker_begin
    Thread.new do
      pid = Process.spawn({
          "filename1"         => filename1,
          "filename2"         => filename2,
          "output_filename"   => output_filename,
          "sort_column"       => @options[:sort_column].to_s,
          "sort_as_int"       => (@options[:parse_as] == :int ? "true" : "false"),
          "column_separator"  => @options[:column_separator]
        }, "ruby #{File.join(File.dirname(__FILE__), 'merger.rb')}")
      Process.waitpid(pid)
      File.delete(filename1)
      File.delete(filename2)
      self.log("Merge complete for (#{fid filename1}, #{fid filename2}) => #{fid output_filename}")
      @files_to_merge << output_filename
      self.worker_done
    end
  end

  def worker_begin
    @active_workers += 1
  end

  def worker_done
    @active_workers -= 1
    @scheduler_thread.wakeup
  end

  def next_filename
    return "#{@filename}.#{(@file_id_counter += 1)}"
  end

  def fid(filename)
    return "F-#{filename.split(".").last}"
  end

  def seconds_to_pretty_time(num_seconds)
    num_seconds = num_seconds.round(0).to_i
    hours = (num_seconds / (60**2)).to_i
    minutes = ((num_seconds % (60**2)) / 60).to_i
    padded_minutes = minutes < 10 ? "0#{minutes}" : minutes.to_s
    seconds = num_seconds % 60
    seconds_padded = seconds < 10 ? "0#{seconds}" : seconds.to_s
    return "#{hours}:#{padded_minutes}:#{seconds_padded}"
  end

  def log(message)
    return unless @options[:log_output]
    puts "#{seconds_to_pretty_time(Time.now - @start_time)} #{message}"
  end

end

#Run as
#FileSort.new("large-file-1000000.csv", {replace_original: false, lines_per_split: 100000}).sort!
#FileSort.new("large-file-10000000.csv", {replace_original: false}).sort!