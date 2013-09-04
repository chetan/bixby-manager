
begin
  require 'single_test/tasks'

rescue LoadError
  warn "single_test not available"
end
