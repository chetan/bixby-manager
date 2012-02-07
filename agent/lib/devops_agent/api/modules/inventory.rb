
class Inventory < BaseModule

    class << self

        def register_agent(uuid, public_key, port, password)
            req = JsonRequest.new("inventory:register_agent",
                { :uuid => uuid, :public_key => public_key,
                  :port => port, :password => password })
            return req.exec()
        end

    end # self

end
