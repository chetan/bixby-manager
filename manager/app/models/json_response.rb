
require 'json'

class JsonResponse

    attr_accessor :result, :message, :data, :code

    def self.from_json(str)
        json = JSON.parse(str)
        obj = new
        json.each{ |k,v| obj.send("#{k}=".to_sym, v) }
        obj
    end

end
