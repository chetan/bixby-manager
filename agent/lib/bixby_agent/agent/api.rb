
module Bixby
class Agent
  module API

    # Execute the given API request
    #
    # @param [JsonRequest] json_req
    # @return [JsonResponse]
    def exec_api(json_req)
      uri = URI.join(BaseModule.manager_uri, "/api").to_s
      begin
        post = json_req.to_json
        if crypto_enabled? and have_server_key? then
          ret = json_req.http_post(uri, encrypt_for_server(post))
          res = decrypt_from_server(ret)
        else
          res = json_req.http_post_json(uri, post)
        end
        return JsonResponse.from_json(res)
      rescue Curl::Err::CurlError => ex
        return JsonResponse.new("fail", ex.message, ex.backtrace)
      end
    end


    # Execute the given API download request
    #
    # @param [JsonRequest] json_req     Request to download a file
    # @param [String] download_path     Location to download requested file to
    # @return [JsonResponse]
    def exec_api_download(json_req, download_path)
      uri = URI.join(BaseModule.manager_uri, "/api").to_s
      begin
        json_req.http_post_download(uri, json_req.to_json, download_path)
        return JsonResponse.new("success")
      rescue Curl::Err::CurlError => ex
        return JsonResponse.new("fail", ex.message, ex.backtrace)
      end
    end

  end # API
end # Agent
end # Bixby
