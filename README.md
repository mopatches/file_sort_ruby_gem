# File Sort Ruby Gem

Sorts files too large to fit in RAM using merge sort on temporary files on the hard drive.

Files must be delimited text. E.g. TSV/tab-delimited or CSV/comma-delimited.

Quoted-delimited files (e.g. CSVs with quotes) aren't currently supported. Written and tested on Ruby 1.9.3.

## Installation
gem install file_sort

## Usage
    require 'file_sort'
    FileSort.new(filename, options).sort!

## Examples:
Default sort (tab-delimited file, sort by first column as a number):

    FileSort.new("my-large-file.tsv").sort!

Sort with options (comma-delimited file, sort by second column as a string):

    FileSort.new("my-large-file.csv", { sort_column: 1, column_separator: ",", parse_as: :string }).sort!

## Options
- **sort_column** - Index for which column to use when comparing rows. Default is 0, the first column.
- **column_separator** - Character to split split on when parsing the input files. Default is "\t", a tab.
- **num_processes** - Number of processes to use in parallel when sorting. Default is 3.
- **parse_as** - Determines how the parsed sort column is compared. Default is :int, other possible values: :string
- **lines_per_split** - The file to sort is split into many smaller temporary files that get sorted and merged together. This determines the size of the temporary files, in number of lines. Default is 1000000.
- **replace_original** - Whether to replace the original file with the sorted version or not. Default is true, to replace. If false a sorted file is left in the same directory as the original file with a .sorted extension.
- **log_output** - Show log/progress messages during sorting. Default is true, show messages.