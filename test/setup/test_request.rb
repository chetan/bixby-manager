
module ActionController
  class TestRequest < ActionDispatch::TestRequest #:nodoc:

    # Monkeypatch to allow passing args straight through when doing JSON create/update requests
    def assign_parameters(routes, controller_path, action, parameters = {})
      parameters = parameters.symbolize_keys.merge(:controller => controller_path, :action => action)
      extra_keys = routes.extra_keys(parameters)
      non_path_parameters = get? ? query_parameters : request_parameters
      parameters.each do |key, value|
        if value.is_a?(Array) && (value.frozen? || value.any?(&:frozen?))
          value = value.map{ |v| v.duplicable? ? v.dup : v }
        elsif value.is_a?(Hash) && (value.frozen? || value.any?{ |k,v| v.frozen? })
          value = Hash[value.map{ |k,v| [k, v.duplicable? ? v.dup : v] }]
        elsif value.frozen? && value.duplicable?
          value = value.dup
        end

        if extra_keys.include?(key.to_sym)
          non_path_parameters[key] = value
        else
          if value.is_a?(Array)
            value = value.map(&:to_param)
          elsif !(parameters[:format].to_s == "json" && action =~ /create|update/) then
            # MONKEYPATCH: don't modify value for create/update json actions
            value = value.to_param
          end

          path_parameters[key.to_s] = value
        end
      end

      # Clear the combined params hash in case it was already referenced.
      @env.delete("action_dispatch.request.parameters")

      # Clear the filter cache variables so they're not stale
      @filtered_parameters = @filtered_env = @filtered_path = nil

      params = self.request_parameters.dup
      %w(controller action only_path).each do |k|
        params.delete(k)
        params.delete(k.to_sym)
      end
      data = params.to_query

      @env['CONTENT_LENGTH'] = data.length.to_s
      @env['rack.input'] = StringIO.new(data)
    end

  end
end
