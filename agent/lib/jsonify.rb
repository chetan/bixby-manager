
module Jsonify
    def to_json
        self.to_json_properties.inject({}) { |h,k| h[k[1,k.length]] = self.instance_eval(k); h }.to_json
    end
    def to_json_properties
        self.instance_variables
    end
end
