
module MultiTenant

  # Included into ActionController::Base to allow easy access to the
  # current_tenant
  module ControllerExtensions
    def multi_tenant
      self.class_eval do
        helper_method :current_tenant
        after_filter :clear_current_tenant

        private

        # helper method to have the current_tenant available in the controller
        def current_tenant
          MultiTenant.current_tenant
        end

        # Clear current tenant after the request is completed
        def clear_current_tenant
          MultiTenant.current_tenant = nil
        end
      end
    end
  end

end
