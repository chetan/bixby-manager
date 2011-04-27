
require 'api/json_request'
require 'api/json_response'

module Inventory

    class << self

        def register_agent(request, params)

            p params

            a = Agent.new
            a.ip = request.remote_ip
            a.port = params[:port]
            a.uuid = params[:uuid]
            a.public_key = params[:public_key]

            if not a.valid? then
                # validate this agent first
                msg = ""
                a.errors.keys.each { |k| msg += "; " if not msg.empty?; msg += "#{k}: #{a.errors[k]}" }
                return JsonResponse.new(:fail, msg)
            end

            a.save!

            return nil
        end

    end # self

end
