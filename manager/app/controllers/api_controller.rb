
require 'bixby/modules/provisioning'
require 'bixby/modules/inventory'
require 'bixby/file_download'

class ApiController < ApplicationController

    skip_before_filter :verify_authenticity_token

    def handle

        # extract JsonRequest

        req = extract_request()
        if req.kind_of? JsonResponse then
            return render :json => req.to_json
        end


        # validate request of form: operation = "module_name:method_name"

        mod = op = nil
        if req.operation.include? ":" then
            (mod, op) = req.operation.split(/:/)
        end

        if mod.blank? or op.blank? then
            return unsupported_operation(req)
        end

        begin
            mod = "Bixby::#{mod.camelize}"
            mod = mod.constantize.new(request, req)
            op = op.to_sym
            if not (mod and mod.respond_to? op) then
                return unsupported_operation(req)
            end
        rescue Exception => ex
            return unsupported_operation(req)
        end


        # execute request

        begin
            # request = http request object
            if req.params.kind_of? Hash then
                ret = mod.send(op, HashWithIndifferentAccess.new(req.params))
            elsif req.params.kind_of? Array then
                ret = mod.send(op, *req.params)
            else
                ret = mod.send(op, req.params)
            end
            if ret.kind_of? Bixby::FileDownload then
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


    # Helper for creating JsonResponse
    def unsupported_operation(req)
        JsonResponse.invalid_request("unsupported operation: '#{req.operation}'")
    end

    # Extract JsonRequest
    def extract_request

        # extract JsonRequest

        body = request.body.read.strip
        if body.blank? then
            return JsonResponse.invalid_request
        end

        begin
            req = JsonRequest.from_json(body)
        rescue Exception => ex
            return JsonResponse.invalid_request
        end

        if req.operation.blank? then
            return JsonResponse.invalid_request
        end

        return req
    end

end
