
require 'sinatra/base'

require File.dirname(__FILE__) + "/rpc"

class Server < Sinatra::Base

    get '/op/:operation' do
        operation_name = params[:operation]

        operation = agent.get_operation(operation_name)
        if operation == nil
            agent.provision_operation(operation_name)
            operation = agent.get_operation(operation_name)
        end

        if operation != nil
            operation.execute
        else
            "Unknown operation #{params[:operation]}"
        end
    end

end
