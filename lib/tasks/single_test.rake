
begin
  require 'single_test'
  SingleTest.load_tasks

rescue LoadError
  warn "single_test not available"
end
