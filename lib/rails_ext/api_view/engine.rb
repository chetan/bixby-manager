
module ApiView
  class Engine

    class << self

      # Render the given object as JSON or XML
      #
      # @param [Object] obj
      # @param [ActionDispatch::Request] scope
      # @param [Hash] options
      # @option options [String] :format    Request a particular format ("json" or "xml")
      #
      # @return [String]
      def render(obj, scope, options={})

        ret = convert(obj)

        if ret.kind_of? String then
          return ret # already converted (by default converter, for ex)
        end

        # TODO cache_results { self.send("to_" + format.to_s) }
        format = options[:format] || self.request_format(scope)
        self.send("to_" + format.to_s, ret)
      end

      # Convert the given object into a hash, array or other simple type
      # (String, Fixnum, etc) that can be easily serialized into JSON or XML.
      #
      # @param [Object] obj
      # @return [Object]
      def convert(obj)

        if [String, Fixnum, Float].include? obj.class then
          return obj # already converted
        end

        if obj.kind_of?(Hash) then
          ret = {}
          obj.each{ |k,v| ret[k] = convert(v) }
          return ret

        elsif obj.respond_to?(:map) then
          return obj.map { |o| convert(o) }

        else
          return ApiView.converter_for(obj.class).convert(obj)
        end

      end

      # Returns a JSON representation of the data object
      def to_json(obj)
        MultiJson.dump(obj)
      end

      # Returns an XML representation of the data object
      def to_xml(obj)
        obj.to_xml()
      end

      # Returns a guess at the format in this scope
      # request_format => "xml"
      def request_format(scope)
        params = scope.respond_to?(:params) ? scope.params : {}
        format = params.has_key?(:format) ? params[:format] : nil
        if request = scope.respond_to?(:request) && scope.request
          format ||= request.format.to_sym.to_s if request.respond_to?(:format)
        end
        format && self.respond_to?("to_#{format}") ? format : "json"
      end

    end

  end # Engine
end # ApiView
