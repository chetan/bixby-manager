
require 'rails_ext/rack_request'
require 'rails_ext/multi_tenant'
require 'rails_ext/csv_column'
require 'rails_ext/json_column'
require 'rails_ext/symbol_column'
require 'rails_ext/api_view/api_view'

if ! Rails.env.test? then
  begin
    require 'rails_ext/console_table'
  rescue LoadError
  end
end
