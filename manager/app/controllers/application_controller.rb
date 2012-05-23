class ApplicationController < ActionController::Base
  protect_from_forgery
  respond_to :html, :json
  before_filter :init_bootstrap


  protected

  def bootstrap(*args)
    opts = args.extract_options!
    type = opts.delete(:type)

    args.each do |obj|
      bootstrap_obj(obj, type)
    end
  end


  private

  def init_bootstrap
    @bootstrap = []
  end

  # bootstrap the given object
  # automatically sets the hash and model names based on the type of object passed
  # (i.e. pluralizes and adds List for arrays, etc)
  def bootstrap_obj(obj, type=nil)
    if type.nil? then

      if obj.kind_of? ActiveRecord::Base then
        type = obj.class.to_s
        name = type.downcase

      elsif obj.kind_of? ActiveRecord::Relation or obj.kind_of? Array then
        return if obj.empty?
        type = obj.first.class.to_s + "List"
        name = obj.first.class.to_s.pluralize.downcase
      end

      data = obj.to_api

    else
      name = type.to_s.pluralize.downcase
      type = type.to_s + "List"
      data = obj
    end

    @bootstrap << {
      :name  => name,
      :model => type,
      :data  => data
    }
  end

end
