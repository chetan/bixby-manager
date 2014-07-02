
class Rest::Models::AnnotationsController < ::Rest::BaseController

  def index
    if params[:name] then
      restful Annotation.where(:org_id => current_user.org.id, :name => params[:name])
    else
      restful Annotation.where(:org_id => current_user.org.id)
    end
  end

end
