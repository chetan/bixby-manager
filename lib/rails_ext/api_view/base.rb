
module ApiView

  class Base

    class << self

      def for_model(model)
        ApiView.add_model(model, self)
      end

      def attrs(obj, *attrs)
        return {} if attrs.blank?
        if attrs.size == 1 and attrs.first == :all then
          return obj.serializable_hash
        end

        ret = {}
        attrs.each do |a|
          ret[a.to_sym] = obj.send(a.to_sym)
        end
        return ret
      end

      def attrs_except(obj, *attrs)
        return obj.serializable_hash({ :except => attrs })
      end

      def render(obj)
        Engine.convert(obj)
      end

    end


  end

  class Default < Base
    def self.convert(obj)
      if obj.respond_to? :to_api then
        obj.to_api
      elsif obj.respond_to? :to_hash then
        obj.to_hash
      elsif obj.respond_to? :serializable_hash then
        obj.serializable_hash
      else
        obj
      end
    end
  end # Default

end
