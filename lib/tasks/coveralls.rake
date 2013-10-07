
desc "Report coverage to coveralls"
task :coveralls do
  require "easycov"
  require "coveralls"

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  if File.exists? File.join(EasyCov.path, ".resultset.json") then
    SimpleCov::ResultMerger.merged_result.format!
  end
end
