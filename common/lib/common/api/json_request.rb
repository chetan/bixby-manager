
require "util/http_client"
require "util/jsonify"
require "api/json_response"
require "api/modules/base_module"

class JsonRequest

    include Jsonify
    include HttpClient

    attr_accessor :operation, :params

    def initialize(operation, params)
        @operation = operation
        @params = params
    end

    def exec(uri = nil)
        uri ||= api_uri
        return JsonResponse.from_json(http_post_json(uri, self.to_json))
    end

    def exec_download(download_path, uri = nil)
        uri ||= api_uri
        http_post_download(uri, self.to_json, download_path)
    end
end
