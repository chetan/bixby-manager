
module MultiTenant

  # Included into ActionController::Base to allow easy access to the
  # current_tenant
  module ControllerExtensions
    def multi_tenant
      self.class_eval do
        helper_method :current_tenant
        around_action :verify_tenant_access

        private

        # helper method to have the current_tenant available in the controller
        def current_tenant
          MultiTenant.current_tenant
        end

        # Clear current tenant after the request is completed
        def verify_tenant_access
          begin

            yield

            MultiTenant.pending_verification.each do |pending|
              rec, model = pending
              curr_id = MultiTenant.current_tenant.id

              multi_tenant_incr(rec)

              rec_tenant = rec.send(model)
              if rec_tenant.nil? then
                # if no tenant, then must be globally accessible
                multi_tenant_decr()
                return
              end

              other_id = rec_tenant.id
              if curr_id != other_id then
                # PANIC
                multi_tenant_reset()
                raise AccessException, "illegal access: tried to access tenant.id=#{other_id}; current_tenant.id=#{curr_id}"
              end

              multi_tenant_decr()
            end

          ensure
            MultiTenant.pending_verification.clear
            MultiTenant.current_tenant = nil
          end
        end


        def multi_tenant_logger
          Logging.logger[ActiveRecord::Base]
        end

        def multi_tenant_incr(rec)
          return if !multi_tenant_logger.debug?
          RequestStore.store[:multi_tenant_verify] ||= 0
          if (RequestStore.store[:multi_tenant_verify] += 1) == 1 then
            multi_tenant_logger.debug { "MULTI_TENANT CHECK (#{rec.class}) {" }
          end
        end

        def multi_tenant_reset
          return if !multi_tenant_logger.debug?
          RequestStore.store[:multi_tenant_verify] = 0
        end

        def multi_tenant_decr
          return if !multi_tenant_logger.debug?
          if (RequestStore.store[:multi_tenant_verify] -= 1) <= 0 then
            multi_tenant_logger.debug { "} # MULTI_TENANT OK" }
          end
        end

      end
    end
  end

end
