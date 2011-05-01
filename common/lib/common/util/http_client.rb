
require 'curb'
require 'json'

module HttpClient

    def create_url(path)
        path = "/#{path}" if path[0,1] != '/'
        manager_uri = get_manager_uri()
        "#{manager_uri}#{path}"
    end

    def http_get(url)
        Curl::Easy.http_get(url).body_str
    end

    # make an HTTP GET request and parse the JSON response
    def http_get_json(url)
        JSON.parse(http_get(url))
    end

    def create_post_data(data)
        if data.kind_of? Hash then
            data = data.map{ |k,v| Curl::PostField.content(k, v) }
        end
        data
    end

    def http_post(url, data)
        return Curl::Easy.http_post(url, create_post_data(data)).body_str
    end

    # make an HTTP POST request and parse the JSON response
    def http_post_json(url, data)
        JSON.parse(http_post(url, data))
    end

    def http_post_download(url, data, dest)
        File.open(dest, "w") do |io|
            c = Curl::Easy.new(url)
            c.on_body { |d| io << d; d.length }
            c.http_post(data)
        end
    end

    def get_manager_uri
        BaseModule.manager_uri
    end

    def api_uri
        create_url("/api")
    end

end
