Apipie.configure do |config|

  config.app_name = "Bixby"
  config.copyright = "&copy; 2012 Pixelcop Research, Inc."
  config.doc_base_url = "/apidoc"
  config.api_base_url = ""
  config.use_cache = Rails.env.production?
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
  config.markup = Apipie::Markup::Markdown.new
  config.validate = true
  # config.app_info = File.read(path)

  # set all parameters as required by default
  # if enabled, use param :name, val, :required => false for optional params
  config.required_by_default = false

  # specify disqus site shortname to show discusion on each page
  # to show it in custom layout, use `render 'disqus' if Apipie.configuration.use_disqus?`
  # config.disqus_shortname = 'paveltest'
end
