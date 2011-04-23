
require "util/jsonify"

class JsonRequest

    include Jsonify

    attr_accessor :operation, :params

    def initialize(operation, params)
        @operation = operation
        @params = params
    end
end
