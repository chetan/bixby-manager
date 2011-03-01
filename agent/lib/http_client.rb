
require 'curb'
require 'json'

module HttpClient

    def create_url(path)
        path = "/#{path}" if path[0,1] != '/'
        "#{manager_uri}#{path}"
    end

    def http_get(url)
        Curl::Easy.http_get(url).body_str
    end

    # make an HTTP GET request and parse the JSON response
    def http_get_json(url)
        JSON.parse(http_get(url))
    end

    def http_post(url, data)
        return Curl::Easy.http_post(url, data.map{ |k,v| Curl::PostField.content(k, v) }).body_str
    end

    # make an HTTP POST request and parse the JSON response
    def http_post_json(url, data)
        JSON.parse(http_post(url, data))
    end

end
