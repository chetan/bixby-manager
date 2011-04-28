
require 'util/http_client'

class BaseModule

    class << self
        attr_accessor :agent

        include HttpClient

        def manager_uri
            BaseModule.agent.manager_uri
        end
    end

end
