
require 'curb'
require 'json'

module HttpClient

   def http_get(url)
       Curl::Easy.http_get(url).body_str
   end

   def http_get_json(url)
       JSON.parse(http_get(url))
   end

end
