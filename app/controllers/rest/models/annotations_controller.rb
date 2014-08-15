
class Rest::Models::AnnotationsController < ::Rest::BaseController

  def index

    if (detail = params[:detail]) && detail !~ /^(.*)=(.*)$/ then
      return render :json => "invalid detail query", :status => 400
    end

    opts = {:org_id => current_user.org.id}

    # add name
    name = params[:name]
    name.strip! if name
    if !name.blank? then
      opts[:name] = name
    end

    # add detail filter
    extra = nil
    if detail then
      # include the filter value in a like query for some simple filtering
      # good for now but want to fix later
      k, v = detail.split("=")
      k.strip!
      v.strip!
      extra = "detail like '%#{v}%'"
    end

    # always limit to 20 (for now) most recent annotations
    annotations = Annotation.where(opts).where(extra).order(:created_at => :desc).limit(20)

    if !detail then
      return annotations
    end

    # assume we have json in the annotation detail field and filter it further
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
