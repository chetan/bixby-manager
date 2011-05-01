
require "util/http_client"
require "util/jsonify"

class JsonRequest

    include Jsonify
    include HttpClient

    attr_accessor :operation, :params

    def initialize(operation, params)
        @operation = operation
        @params = params
    end

    def exec
        return JsonResponse.from_json(http_post_json(BaseModule.create_url("/api"), self.to_json))
    end

    def exec_download(download_path)
        http_post_download(BaseModule.create_url("/api"), self.to_json, download_path)
    end
end
