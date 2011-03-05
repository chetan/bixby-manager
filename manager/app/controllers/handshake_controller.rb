
class HandshakeController < ApplicationController

	def register

	    body = request.body.read.strip
	    if body.blank? then
	        # TODO error
            return render :text => "error\n"
        end

	    req = JsonRequest.from_json(body)
	    params = HashWithIndifferentAccess.new(req.params)

		public_key = params[:public_key]
		if public_key.blank? then
		    r = JsonResponse.new
		    r.result = :error
		    r.message = "public_key is required"
		    return render :json => r
	    end

	    uuid = params[:uuid]
	    if uuid.blank? then
		    r = JsonResponse.new
		    r.result = :error
		    r.message = "uuid is required"
		    return render :json => r
        end

        if not (Agent.where(:public_key => public_key).empty? and Agent.where(:uuid => uuid).empty?) then
            r = JsonResponse.new
            r.result = :error
            r.message = "agent already exists"
            return render :json => r
        end

		a = Agent.new
		a.ip = request.remote_ip
		a.uuid = uuid
		a.public_key = public_key
		a.save!

		r = JsonResponse.new
		r.result = :success

		render :json => r
	end

end
