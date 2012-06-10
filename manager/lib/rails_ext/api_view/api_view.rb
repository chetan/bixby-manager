
require 'rails_ext/api_view/engine'
require 'rails_ext/api_view/base'

module ApiView

  class << self

    def models
      @models ||= {}
    end

    def add_model(model, converter)
      models[model.to_s] = converter
    end

    def converter_for(clazz)
      models[clazz.to_s] || ApiView::Default
    end

  end

end
