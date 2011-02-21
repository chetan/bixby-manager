
class RepoController < ApplicationController
	
    def fetch
        
        name = params[:name]
        
        base_url = "#{request.scheme}://#{request.raw_host_with_port}/repo"
        
        # resolve requested resource to actual filename + potentially dependencies
        files = [ "#{base_url}/bin/#{name}.rb" ]
        
        render :json => { :files => files }
        
    end
	
end