
desc "Run micron tests"
task :test do
  ARGV.shift if ARGV.first == "test"
  cmd = "micron #{ARGV.join(' ')}"
  STDERR.puts "NOTE: you should simply run 'micron' directly: #{cmd}\n"
  exec(cmd)
end

task :default => :test
