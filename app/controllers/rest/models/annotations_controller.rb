
class Rest::Models::AnnotationsController < ::Rest::BaseController

  def index

    if (detail = params[:detail]) && detail !~ /^(.*)=(.*)$/ then
      return render :json => "invalid detail query", :status => 400
    end

    annotations = if params[:name] then
      Annotation.where(:org_id => current_user.org.id, :name => params[:name])
    else
      Annotation.where(:org_id => current_user.org.id)
    end

    if !detail then
      return annotations
    end

    # assume we have json in the annotation detail field and filter it further
    k, v = params[:detail].split("=")
    k.strip!
    v.strip!

    matches = []
    annotations.each do |a|
      next if a.detail.blank?
      begin
        d = MultiJson.load(a.detail)
        next if not d.kind_of? Hash
        if d[k] == v then
          matches << a
        end
      rescue MultiJson::ParseError => exception
        next
      end
    end

    return matches
  end

end
