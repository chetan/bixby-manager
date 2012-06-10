
module ApiView

  class Base

    def self.for_model(model)
      ApiView.add_model(model, self)
    end

    def self.attrs(obj, *attrs)
      ret = {}
      attrs.each do |a|
        ret[a.to_sym] = obj.send(a.to_sym)
      end
      return ret
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
