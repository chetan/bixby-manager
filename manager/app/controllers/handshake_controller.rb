
class HandshakeController < ApplicationController
	
	def register
		
		ip = params[:ip]
		if ip.blank? then
		    r = Response.new
		    r.result = :error
		    r.message = "ip is required"
		    return render :json => r
	    end
	    
	    uuid = params[:uuid]
	    if uuid.blank? then
		    r = Response.new
		    r.result = :error
		    r.message = "uuid is required"
		    return render :json => r
        end
        
        if not Agent.where(:ip => ip).empty? then
            r = Response.new
            r.result = :error
            r.message = "agent already exists"
            return render :json => r
        end
	    	    
		a = Agent.new
		a.ip = ip
		a.uuid = uuid
		a.save!
		
		r = Response.new
		r.result = :success

		render :json => r		
	end
	
end