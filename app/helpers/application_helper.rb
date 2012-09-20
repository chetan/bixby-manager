module ApplicationHelper

end

# hack to get this to work in haml
if Object.const_defined? "LoremIpsum" then
  module Haml::Helpers
    include ::LoremIpsum::Base
  end
end
