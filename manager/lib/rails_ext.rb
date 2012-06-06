
require 'rails_ext/json_column'
require 'rails_ext/to_api'

# these should only be used in non-production environments
if Rails.env != "production" then
  require 'rails_ext/migration'
end
