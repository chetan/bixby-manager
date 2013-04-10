
::SecureHeaders::Configuration.configure do |config|
  config.hsts = false # let Rack::SSL handle this
  config.x_frame_options = 'DENY'
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = {:value => 1, :mode => false}

  # see
  # https://github.com/twitter/secureheaders
  # https://www.owasp.org/index.php/Content_Security_Policy
  # http://www.html5rocks.com/en/tutorials/security/content-security-policy/

  # config.csp = {
  #   :default_src => "https://* inline eval",
  #   :report_uri => '//example.com/uri-directive',
  #   :img_src => "https://* data:",
  #   :frame_src => "https://* http://*.twimg.com http://itunes.apple.com"
  # }
end
