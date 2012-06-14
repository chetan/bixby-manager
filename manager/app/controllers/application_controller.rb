class ApplicationController < ActionController::Base
  protect_from_forgery
  respond_to :html, :json
  before_filter :init_bootstrap


  protected

  # Bootstrap a list of models
  #
  # @param [Object] *models           List of models to bootstrap
  # @param [Hash] options             Options hash
  # @option options [String] :type    The name of the Backbone.js Model class to map to
  def bootstrap(*args)
    opts = args.extract_options!
    args.each do |obj|
      bootstrap_obj(obj, opts)
    end
  end

  # Extracts the given keys from params().
  #
  # The hash to filter can optionally be passed as the first paramater.
  #
  # Common usage:
  #
  #   @model.update_attributes pick(:name, :desc)
  #
  # @param [Array] keys     Key names to filter by
  #
  # @return [Hash] filtered key/value pairs
  def pick(*keys)

    # default to params()
    hash = keys.first.kind_of?(Hash) ? keys.shift : params()

    filtered = {}
    hash.each do |key, value|
      filtered[key.to_sym] = value if keys.include?(key.to_sym)
    end
    filtered
  end

  # Restful response
  #
  # Handles HTML request normally; XML/JSON requests are handled using
  # ApiView::Engine to generate the response
  #
  # @param [Object] obj
  def restful(obj)
    respond_to do |format|
      format.html
      format.any(:xml, :json) { render :text => to_api(obj) }
    end
  end

  # Helper for rendering obj via ApiView
  #
  # @param [Object] obj
  # @return [String]
  def to_api(obj)
    ApiView::Engine.render(obj, self).html_safe
  end


  private

  def init_bootstrap
    @bootstrap = []
  end

  # bootstrap the given object
  # automatically sets the hash and model names based on the type of object passed
  # (i.e. pluralizes and adds List for arrays, etc)
  def bootstrap_obj(obj, opts)

    type = opts.delete(:type)
    if type.nil? then

      if obj.kind_of? ActiveRecord::Base then
        type = obj.class.to_s
        name = type.downcase

      elsif obj.kind_of? ActiveRecord::Relation or obj.kind_of? Array then
        return if obj.empty?
        type = obj.first.class.to_s + "List"
        name = obj.first.class.to_s.pluralize.downcase
      end

    else
      name = type.to_s.pluralize.downcase
      type = type.to_s + "List"
    end

    @bootstrap << {
      :name  => name,
      :model => type,
      :data  => to_api(obj)
    }
  end

end
