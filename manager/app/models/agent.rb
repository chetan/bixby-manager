
class Agent < ActiveRecord::Base
	
	def get_uptime
		
		puts Curl::Easy.http_get("http://#{ip}:4567/uptime").body_str
		
	end
	
end
