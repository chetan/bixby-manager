
require 'json'

module Jsonify
    def to_json
        self.to_json_properties.inject({}) { |h,k| h[k[1,k.length]] = self.instance_eval(k); h }.to_json
    end
    def to_json_properties
        self.instance_variables
    end

    module ClassMethods
        def from_json(json)
            json = JSON.parse(json) if json.kind_of? String
            obj = self.allocate
            json.each{ |k,v| obj.send("#{k}=".to_sym, v) }
            obj
        end
    end

    def self.included(receiver)
        receiver.extend(ClassMethods)
    end
end
