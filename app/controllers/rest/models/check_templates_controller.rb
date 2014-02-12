
class Rest::Models::CheckTemplatesController < ::Rest::ApiController

  def create

    # Parameters: {
    #   "name"=>"test", "mode"=>"all", "tags"=>"test,dev",
    #   "items"=>[
    #     {"command_id"=>1, "args"=>{}},
    #     {"command_id"=>2, "args"=>{}}],
    #   "check_template"=>{"name"=>"test", "mode"=>"all", "tags"=>"test,dev"}
    # }

    ct = ActiveRecord::Base.transaction do
      ct = CheckTemplate.new(pick(:name, :mode, :tags))
      ct.org_id = current_user.org_id
      ct.save!

      params[:items].each do |item|

        cti = CheckTemplateItem.new
        cti.check_template_id = ct.id
        cti.command_id = item[:command_id]

        args = item[:args]
        if args.blank? then
          args = nil
        else
          args.delete_if{ |k,v| v.nil? or v.empty? } # remove empty args
        end
        cti.args = args

        cti.save!
      end

      ct
    end

    restful ct
  end

end
