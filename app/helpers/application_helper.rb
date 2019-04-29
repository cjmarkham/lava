require 'open-uri'

module ApplicationHelper
    def MoltinRequest path, method, data = {}, auth = false
        uri = URI ENV['MOLTIN_BASE_URL'].dup << path
        uri = URI 'https://api.moltin.com' << path if auth

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        headers = {
            'Content-Type': 'application/json',
            'X-Moltin-Currency': @currency,
        }

        if ! auth
            headers['Authorization'] = "Bearer: #{@access_token}"
        end

        data = auth ? URI.encode_www_form(data) : data.to_json

        res = case method.to_sym
        when :get
            http.get(uri.path << ("?#{uri.query}" || ''), headers)
        when :post
            http.post(uri.path, data, headers)
        when :delete
            http.delete(uri.path, headers)
        when :put
            http.put(uri.path, data, headers)
        end

        return res
    end
end
