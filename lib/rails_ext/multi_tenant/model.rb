

module MultiTenant

  # Included into ActiveRecord::Base, this is where security checks occur
  module ModelExtensions
    extend ActiveSupport::Concern
    module ClassMethods

      # Mark the model as being part of a multi-tenant system. Enforces
      # the tenant security model.
      def multi_tenant(opts={})

        model = (opts.delete(:model) || :tenant).to_sym

        if opts.include? :via then
          define_method model do
            via = self.send(opts[:via])
            return nil if via.nil?
            return via.send(model)
          end

        elsif respond_to? model or reflect_on_all_associations(:belongs_to).find{ |a| a.name == model } then
          # just use the current accessor

        else
          raise "don't know how to locate #{model}"

        end

        self.after_find lambda { |rec|
          return if rec.nil? or MultiTenant.current_tenant.nil?
          curr_id = MultiTenant.current_tenant.id

          multi_tenant_incr()

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
        }

      end # multi_tenant

    end # ClassMethods

    def multi_tenant_logger
      Logging.logger[ActiveRecord::Base]
    end

    def multi_tenant_incr
      return if !multi_tenant_logger.debug?
      RequestStore[:multi_tenant_verify] ||= 0
      if (RequestStore[:multi_tenant_verify] += 1) == 1 then
        multi_tenant_logger.debug { "MULTI_TENANT CHECK {" }
      end
    end

    def multi_tenant_reset
      return if !multi_tenant_logger.debug?
      RequestStore[:multi_tenant_verify] = 0
    end

    def multi_tenant_decr
      return if !multi_tenant_logger.debug?
      if (RequestStore[:multi_tenant_verify] -= 1) <= 0 then
        multi_tenant_logger.debug { "} # MULTI_TENANT OK" }
      end
    end

  end # ModelExtensions

end
