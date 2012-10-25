
require 'rake/hooks'

# force display of coverage after running all tests
after 'test:integration' do
  puts
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov::Formatter::Console.new.format(SimpleCov.result)
end
