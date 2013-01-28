Gem::Specification.new do |s|
  s.name        = 'file_sort'
  s.version     = '0.0.2'
  s.date        = '2013-01-27'
  s.summary     = "FileSort - Sorts files too large to fit in RAM"
  s.description = "Sorts large files using merge sort on temporary files on the hard drive."
  s.authors     = ["Tom O'Neill"]
  s.email       = 'tom.oneill@live.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/mopatches/file_sort_ruby_gem'
  s.platform    = Gem::Platform::RUBY
end