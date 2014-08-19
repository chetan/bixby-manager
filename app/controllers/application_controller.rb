
# temp workaround for load order issues
# ApplicationController now gets loaded at various different points in the process
require "rails_ext/multi_tenant"
require "archie/controller"
require "archie/otp"

class ApplicationController < ActionController::Base

  include Archie::Controller
  include Archie::OTP::Controller

  protect_from_forgery
  respond_to :html, :json
  multi_tenant

  # Placeholder route for simply returning bootstrap html
  def default_route
    render :index
  end

  protected

  # Bootstrap a list of models
  #
  # @param [Object] *models           List of models to bootstrap
  # @param [Hash] options             Options hash
  # @option options [String] :type    The name of the Backbone.js Model class to map to
  # @option options [String] :name    The key name to bootstrap asA
  # @option options [Class] :use      ApiView view class to render with
  #
  # Note: passing a type will force the object to be bootstrapped even if
  #       nil or an empty array is passed in (i.e., when the finder comes up empty)
  def bootstrap(*args)
    opts = args.extract_options!
    args.each do |obj|
      bootstrap_obj(obj, opts)
    end
  end

  # Extracts the given keys from params(). IDs (params ending in '_id') will
  # automatically be cast to an integer.
  #
  # The hash to filter can optionally be passed as the first paramater.
  #
  # Common usage:
  #
  #   @model.update_attributes pick(:name, :desc)
  #
  # @param [Hash] input     Input hash (optional, default: params)
  # @param [Array] keys     Key names to filter by
  #
  # @return [Hash] filtered key/value pairs
  def pick(*keys)

    # default to params()
    hash = keys.first.kind_of?(Hash) ? keys.shift : params()

    filtered = {}
    keys.each do |key|
      if hash.include? key then
        value = hash[key]
        value = value.to_i if key =~ /_id$/ # force ids to_i
        filtered[key] = value
      end
    end
    filtered
  end

  # Fetch the given key as an integer
  #
  # @param [Symbol] key         (default: "id")
  # @param [Boolean] optional   Whether or not to raise if param doesn't exist
  #
  # @return [Fixnum] Requested value as an integer, or nil if optional param not found
  # @raise [Exception] Will raise if param is not a string (array or hash) or doesn't exist
  def _id(key = :id, optional=false)
    if params.include? key then
      return params[key].to_i
    elsif key != :id
      key = "#{key.to_s}_id"
      return params[key].to_i if params.include? key
    end

    # try to figure out key name from controller
    controller_key = params[:controller].split("/").last.singularize + "_id"
    if params.include? controller_key
      return params[controller_key].to_i
    end

    if not optional then
      raise MissingParam, "Couldn't find param :id or :#{key} or :#{controller_key}"
    end

    return nil
  end

  # Restful response
  #
  # Handles HTML request normally; XML/JSON requests are handled using
  # ApiView::Engine to generate the response
  #
  # @param [Object] obj
  # @param [Hash] opts           optional options for ApiView render call
  def restful(obj, opts=nil)
    if request.xhr? then
      return render :text => to_api(obj, opts), :as => :json
    end
    respond_to do |format|
      format.html
      format.any(:xml, :json) { render :text => to_api(obj, opts) }
    end
  end

  # Helper for rendering obj via ApiView
  #
  # @param [Object] obj
  # @return [String]
  def to_api(obj, opts=nil)
    logger.debug { "TO_API " + (obj.respond_to?(:first) ? obj.first.class.name : obj.class.name) }
    ApiView::Engine.render(obj, self, opts).html_safe
  end


  private

  # bootstrap the given object into
  # automatically sets the hash and model names based on the type of object passed
  # (i.e. pluralizes and adds List for arrays, etc)
  def bootstrap_obj(obj, opts)

    type = opts.delete(:type) || opts.delete(:model)
    name = opts.delete(:name)
    api_opts = opts[:use] ? { :use => opts.delete(:use) } : nil

    if type.nil? then

      # infer the type from the object
      # set name based on type, if not given
      if obj.kind_of? ActiveRecord::Base then
        type = obj.class.to_s
        name ||= type.underscore

      elsif obj.kind_of? ActiveRecord::Relation or obj.kind_of? Array then
        return if obj.empty? # can't determine type or name

        if obj.first.kind_of? ActiveRecord::Base then
          type = obj.first.class.to_s + "List"
          name ||= obj.first.class.to_s.underscore.pluralize

        elsif obj.first.kind_of? String then
          type = "Array"
          # assume name is passed in
        end

      end

    elsif type !~ /List$/ && obj.respond_to?(:to_a) then
      name ||= type.to_s.underscore.pluralize
      type = type.to_s + "List"

    elsif name.blank?
      name = type.to_s.underscore

    end

    logger.debug { "BOOTSTRAP #{name} (#{type})" }

    @bootstrap ||= []
    @bootstrap << {
      :name  => name.to_s,
      :model => type.to_s,
      :data  => to_api(obj, api_opts)
    }
  end

end
