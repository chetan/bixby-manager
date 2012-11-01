
require 'rails_ext/csv_column'
require 'rails_ext/json_column'
require 'rails_ext/symbol_column'
require 'rails_ext/api_view/api_view'

# these should only be used in non-production environments
if Rails.env != "production" then
  require 'rails_ext/migration'
end
