
class HandshakeController < ApplicationController

    def register

        body = request.body.read.strip
        if body.blank? then
            # TODO error
            return render :text => "error\n"
        end

        req = JsonRequest.from_json(body)
        params = HashWithIndifferentAccess.new(req.params)

        a = Agent.new
        a.ip = request.remote_ip
        a.port = params[:port]
        a.uuid = params[:uuid]
        a.public_key = params[:public_key]

        if not a.valid? then
            # validate this agent first
            msg = ""
            a.errors.keys.each { |k| msg += "; " if not msg.empty?; msg += "#{k}: #{a.errors[k]}" }
            r = JsonResponse.new(:error, msg)
            return render :json => r
        end

        a.save!

        render :json => JsonResponse.new(:success).to_json
    end

end
