
require 'bixby/modules/provisioning'
require 'bixby/modules/inventory'
require 'bixby/file_download'

class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def handle

    begin

      @agent = nil
      ret = handle_request()

      # return response
      if ret.kind_of? Bixby::FileDownload then
        return send_file(ret.filename, :filename => File.basename(ret.filename))

      elsif ret.kind_of? Bixby::JsonResponse then
        return render(:json => ret.to_json)
      end

      return render(:json => Bixby::JsonResponse.new(:success, nil, ret).to_json)

    rescue Exception => ex
      logger.warn { ex }
      return render(:json => Bixby::JsonResponse.new(:fail, ex.message, ex, 500).to_json)
    end

  end # handle


  private

  # Handle the API request
  #
  # @return [Object, JsonResponse] response can be either a JsonResponse or any other type
  def handle_request
    json_req = extract_request()
    return json_req if json_req.kind_of? Bixby::JsonResponse

    return Bixby::ServerHandler.new(request).handle(json_req)
  end

  # Extract JsonRequest from the POST body
  #
  # @return [JsonRequest]
  def extract_request

    # not sure why we need to rewind first, but we do. some change introduced in rails4
    request.body.rewind if request.body.respond_to?(:rewind)
    body = request.raw_post.strip
    if body.blank? then
      return Bixby::JsonResponse.invalid_request
    end

    begin
      json_req = Bixby::JsonRequest.from_json(body)
    rescue Exception => ex
      return Bixby::JsonResponse.invalid_request
    end

    if json_req.operation.blank? then
      return Bixby::JsonResponse.invalid_request
    end

    return json_req
  end

end # ApiController
