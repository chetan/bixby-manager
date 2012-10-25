
# force display of coverage after running all tests
after 'test:integration' do
  puts
  require 'simplecov'
  SimpleCov.result.format!
end
