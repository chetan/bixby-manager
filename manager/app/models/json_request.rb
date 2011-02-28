
require 'json'

class JsonRequest

    attr_accessor :operation, :params

    def self.from_json(str)
        json = JSON.parse(str)
        obj = new
        json.each{ |k,v| obj.send("#{k}=".to_sym, v) }
        obj
    end

end
