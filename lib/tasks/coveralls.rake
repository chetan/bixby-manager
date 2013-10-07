
desc "Report coverage to coveralls"
task :coveralls do
  require "easycov"
  require "coveralls"

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  cov_file = File.join(EasyCov.path, ".resultset.json")
  if File.exists? cov_file then
    data = MultiJson.load(File.read(cov_file))
    # We report on only the most recent coverage run
    if last_key = data.keys.last then
      SimpleCov::Result.from_hash(last_key => data[last_key]).format!
    end
  end
end
