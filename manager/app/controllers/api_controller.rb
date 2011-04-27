
require 'api/json_request'
require 'api/json_response'

require 'modules/provisioning'
require 'modules/inventory'

class ApiController < ApplicationController

    def handle

        # p request
        # puts request.body
        # puts params.to_s

        req = extract_valid_request()
        if req.kind_of? String then
            return render :json => req
        end

        mod = nil
        op = req.operation
        if op.include? ":" then
            (mod, op) = op.split(/:/)
        end

        if mod.blank? or op.blank? then
            return unsupported_operation(req)
        end

        p mod
        p op

        begin
            mod = mod.camelize.constantize
            op = op.to_sym
            if not (mod and mod.respond_to? op) then
                return unsupported_operation(req)
            end
        rescue Exception => ex
            return unsupported_operation(req)
        end

        begin
            ret = mod.send(op, request, HashWithIndifferentAccess.new(req.params))
            if ret.kind_of? FileDownload then
                return send_file(ret.filename, :filename => File.basename(ret.filename))

            elsif ret.kind_of? JsonResponse then
                return render :json => ret
            end

            return render :json => JsonResponse.new(:success, nil, ret)

        rescue Exception => ex
            puts ex
            puts ex.backtrace
            return render :json => JsonResponse.new(:fail, ex.message, ex, 500)
        end
    end

    def unsupported_operation(req)
        render :json => JsonResponse.invalid_request("unsupported operation: #{req.operation}").to_json
    end

    def extract_valid_request
        body = request.body.read.strip
        if body.blank? then
            return JsonResponse.invalid_request.to_json
        end

        begin
            req = JsonRequest.from_json(body)
        rescue Exception => ex
            return JsonResponse.invalid_request.to_json
        end

        # TODO need some sort of pluggable system here..
        # if not SUPPORTED_OPERATIONS.include? req.operation then
        #     return JsonResponse.invalid_request("unsupported operation: #{req.operation}").to_json
        # end

        return req
    end

end
