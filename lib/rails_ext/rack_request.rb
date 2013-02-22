
module Rack
  class Request

    # Override addresses to remove from forwarded IPs
    #
    # We want to include originating IPs from private networks
    # so we removed the following regexes from below:
    #
    # \A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|
    # \Afd[0-9a-f]{2}:.+|
    #
    # These regexes were taken from a version
    def trusted_proxy?(ip)
      ip =~ /\A127\.0\.0\.1\Z|
             \A::1\Z|
             \Alocalhost\Z|
             \Aunix\Z|
             \Aunix:/ix
    end

  end
end
