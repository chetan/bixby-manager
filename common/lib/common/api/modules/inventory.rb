
require 'api/json_request'
require 'api/json_response'

require 'api/modules/base_module'

class Inventory < BaseModule

    class << self

        def register_agent(uuid, public_key, port)
            req = JsonRequest.new("inventory:register_agent", { :uuid => uuid, :public_key => public_key, :port => port })
            url = create_url("/api")
            return JsonResponse.from_json(http_post_json(url, req.to_json))
        end

    end # self

end
