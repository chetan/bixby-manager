module ApplicationHelper

  def navtab(*args)

    if not @current_tab then
      @current_tab = "Inventory"
    end

    li = "li"
    if @current_tab == args.first then
      li += ".active"
    end

    return haml_tag li do
      haml_concat link_to(*args)
    end
  end

end
