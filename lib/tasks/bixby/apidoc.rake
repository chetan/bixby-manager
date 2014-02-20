
begin
  require 'yard'
  require 'ext/yard'

  namespace :bixby do
    desc "Generate API documentation"
    task :apidoc => :yard do
      html = Bixby::APIDoc.render()
      File.open(File.join(Rails.root, 'yardoc', 'index_api.html'), 'w') do |f|
        f.write html
      end
    end
  end

rescue LoadError
end

module Bixby
  class APIDoc

  class << self

  def skip_method?(meth, ignore_methods_from=[])
    skip = false
    skip = true if meth.visibility == :private
    skip = true if meth.is_attribute? or meth.is_alias? or not meth.is_explicit? or meth.module_function?
    skip = true if ignore_methods_from.include? meth.namespace.to_s
    skip = false if meth.constructor?
    return skip
  end

  def print_params(meth)
    ret = []
    f = false
    for param, default in meth.parameters
      if f or not default.nil? then
        f = true
        ret << "#{param} = #{default}"
      else
        ret << param
      end
    end
    if ret.empty? then
      return ""
    end
    "(" + ret.join(", ") + ")"
  end

  def show_methods_for_class(clazz, ignore_methods_from, scope)
    methods = clazz.methods_by_scope(scope)
    return "" if methods.empty?

    ret = []

    if scope == :constructor then
      ret << "  <div class='methods row-fluid'><h3 class='constructor'>Constructor</h3></div>"
    else
      ret << "  <div class='methods row-fluid'><h3 class='#{scope.to_s}_methods'>#{scope.to_s.capitalize} Methods</h3></div>"
    end

    count = 0
    methods.each do |meth|
      next if skip_method? meth, ignore_methods_from
      count += 1
      return_tag = nil
      if not meth.constructor?
        return_tag = meth.tag("return")
        if return_tag then
          return_tag = "<span class='return'>[" + return_tag.types.join(", ") + "]</span> "
        end
      end
      ret << "    <div class='method'>#{return_tag}<strong>#{meth.name.to_s}</strong>#{print_params(meth)}</div>"
      ret << "    <div class='method_summary row-fluid'>"
      ret << "      " + meth.docstring.gsub(/\n/, "<br/>")
      ret << "    </div>"
    end

    if count > 0 then
      ret << "<br/>"
    else
      ret.pop
    end

    ret.join("\n")
  end

  def show_class(mod, ignore_methods_from=[])
    mod = YARD::Registry.at("Bixby::#{mod}")
    if mod.nil? then
      raise "Module '#{mod}' not found"
    end

    ret = []
    ret << "<a id='#{mod.name(true).to_s}-class'></a>"
    ret << "<div class='class well'>"

    name = mod.name(true).to_s
    ret << "<div class='class_header'><h2 class='class'><a href='Bixby/#{name}.html'>#{name}</a></h2></div>"

    ret << show_methods_for_class(mod, ignore_methods_from, :class)
    ret << show_methods_for_class(mod, ignore_methods_from, :constructor) if mod.name.to_s == "API"
    ret << show_methods_for_class(mod, ignore_methods_from, :instance)

    ret << "</div>"
    ret.join("\n")
  end

  def render_api

    ret = []

    # Ignore methods from these modules, which are included in every API module
    ignore_base_modules = %w(Bixby::API Bixby::RemoteExec::Methods Bixby::Crypto
                             Bixby::HttpClient Bixby::Log)

    ret << "<h1>Base class</h1>"
    ret << show_class("API", ignore_base_modules.reject{|m| m == "Bixby::API"})

    ret << "<h1>Core Modules</h1>"
    ret << show_class("RemoteExec", %w(Bixby::API Bixby::Crypto))
    %w(User Repository Provisioning Inventory Scheduler Notifier).each do |mod|
      ret << show_class(mod, ignore_base_modules)
    end

    ret << "<h1>High-level Modules</h1>"
    %w(Metrics Monitoring).each do |mod|
      ret << show_class(mod, ignore_base_modules)
    end

    ret.join("\n")
  end

  def render

    template = <<-EOF
!!!
%html
  %head
    %title Bixby API Reference
    %link{ :href => "http://twitter.github.com/bootstrap/assets/css/bootstrap.css", :rel => "stylesheet" }
    %link{ :href => "http://twitter.github.com/bootstrap/assets/css/bootstrap-responsive.css", :rel => "stylesheet" }
    :css
      div.class_header, div.methods_header {
        border-bottom: 1px solid #EEEEEE;
        margin-bottom: 10px;
        padding-bottom: 0px;
      }
      h2.class {
        padding-bottom: 0px;
        margin-bottom: 0px;
      }
      div.methods_header {
        margin-top: 10px;
      }
      div.method_summary {
        font-size: smaller;
        color: grey;
        margin-bottom: 10px;
      }
      span.return {
        font-style: italic;
      }
  %body

    %div.container-fluid
      %h1
        Bixby API Reference
      = render_api()

  EOF

    Haml::Engine.new(template).render(self)
  end

  end # class << self

  end # APIDoc
end # Bixby
