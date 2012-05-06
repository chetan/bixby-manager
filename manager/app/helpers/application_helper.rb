module ApplicationHelper

  def navtab(*args)

    if not @current_tab then
      @current_tab = "Inventory"
    end

    li = "li"
    if @current_tab == args.first then
      li += ".active"
    end

    haml_tag li do
      haml_concat link_to(*args)
    end
  end

end

# hack to get this to work in haml
if Object.const_defined? "LoremIpsum" then
  module Haml::Helpers
    include ::LoremIpsum::Base
  end
end
