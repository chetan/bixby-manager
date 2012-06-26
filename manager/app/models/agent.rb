
class Agent < ActiveRecord::Base

  belongs_to :host

  STATUS_NEW      = 0
  STATUS_ACTIVE   = 1
  STATUS_INACTIVE = 2

  # validations
  validates_presence_of :port, :uuid, :public_key
  validates_uniqueness_of :uuid, :public_key

  include Bixby::HttpClient

  # execute the given command and return the response
  def run_cmd(cmd)
    req = Bixby::JsonRequest.new("exec", cmd.to_hash)
    return exec_api(req)
  end

  # Execute the given API request
  #
  # @param [JsonRequest] json_req
  # @return [JsonResponse]
  def exec_api(json_req)
    begin
      return Bixby::JsonResponse.from_json(json_req.http_post_json(agent_uri, json_req.to_json))
    rescue Curl::Err::CurlError => ex
      return Bixby::JsonResponse.new("fail", ex.message, ex.backtrace)
    end
  end

  # Execute the given API download request
  #
  # @param [JsonRequest] json_req     Request to download a file
  # @param [String] download_path     Location to download requested file to
  # @return [JsonResponse]
  def exec_api_download(json_req, download_path)
    begin
      json_req.http_post_download(agent_uri, json_req.to_json, download_path)
      return Bixby::JsonResponse.new("success")
    rescue Curl::Err::CurlError => ex
      return Bixby::JsonResponse.new("fail", ex.message, ex.backtrace)
    end
  end

  def agent_uri
    "http://#{self.ip}:#{self.port}/"
  end

end
