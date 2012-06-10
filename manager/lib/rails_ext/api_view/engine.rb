
module ApiView
  class Engine

    class << self

      def render(obj, scope, options={})

        if obj.kind_of? String then
          return obj # already converted
        end

        clazz = obj.respond_to?(:to_a) ? obj.first.class : obj.class
        converter = ApiView.converter_for(clazz)

        if obj.respond_to?(:map) then
          ret = obj.map { |o| converter.convert(o) }
        else
          ret = converter.convert(obj)
        end

        if ret.kind_of? String then
          return ret # already converted (by default converter, for ex)
        end

        # TODO cache_results { self.send("to_" + format.to_s) }
        format = options[:format] || self.request_format(scope)
        self.send("to_" + format.to_s, ret)
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
