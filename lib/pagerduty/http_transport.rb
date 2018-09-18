require "json"
require "net/https"

class Pagerduty
  # @api private
  class HttpTransport
    HOST = "events.pagerduty.com".freeze
    PORT = 443
    PATH = "/generic/2010-04-15/create_event.json".freeze

    def initialize(options = {})
      @options = options
    end

    def send_payload(payload = {})
      response = post payload.to_json
      response.error! unless transported?(response)
      JSON.parse(response.body)
    end

  private

    def post(payload)
      post = Net::HTTP::Post.new(PATH)
      post.body = payload
      http.request(post)
    end

    def http
      http = http_proxy.new(HOST, PORT)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.open_timeout = 60
      http.read_timeout = 60
      http
    end

    def http_proxy
      Net::HTTP.Proxy(
        @options[:proxy_host],
        @options[:proxy_port],
        @options[:proxy_username],
        @options[:proxy_password],
      )
    end

    def transported?(response)
      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    end
  end
end
