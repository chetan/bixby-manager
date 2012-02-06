
module MonitoringHelper

  # display a form for the given Command's options
  def form_for_command(cmd)
    opts = cmd.options
    opts.keys.each do |key|
      case opts[key]["type"]
      when "enum"
        values = [ "/" ] # TODO load actual opts for enum
        t = "command[options][#{key}]"
        html = label_tag(t, key.capitalize + ":")
        html += select_tag(t, options_from_collection_for_select(values, :to_s, :to_s))
        return html
        
      end
    end
  end

  def render_graph(resource)
    return haml_tag "div.na" do
      haml_concat "graph not available"
    end
  end

end
