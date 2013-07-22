# Be sure to restart your server when you modify this file.
#
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json] if respond_to?(:wrap_parameters)
end

# no longer needed in rails 4, false by default
#
# # Disable root element in JSON by default.
# # Required by backbone.js
# ActiveSupport.on_load(:active_record) do
#   self.include_root_in_json = false
# end
