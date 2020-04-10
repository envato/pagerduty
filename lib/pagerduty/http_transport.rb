# frozen_string_literal: true

require "json"
require "net/https"

module Pagerduty
  # @private
  class HttpTransport
    HOST = "events.pagerduty.com"
    PORT = 443
    private_constant :HOST, :PORT

    def initialize(config)
      @path = config.fetch(:path)
      @proxy = config[:proxy] || {}
    end

    def send_payload(payload)
      response = post(payload.to_json)
      response.error! unless transported?(response)
      JSON.parse(response.body)
    end

    private

    def post(payload)
      post = Net::HTTP::Post.new(@path)
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
        @proxy[:host],
        @proxy[:port],
        @proxy[:username],
        @proxy[:password],
      )
    end

    def transported?(response)
      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    end
  end
end
