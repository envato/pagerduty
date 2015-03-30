# encoding: utf-8
require "json"
require "net/https"

# @api private
module Pagerduty::HttpTransport
  HOST = "events.pagerduty.com"
  PORT = 443
  PATH = "/generic/2010-04-15/create_event.json"

  def self.send_payload(payload = {})
    response = post payload.to_json
    response.error! unless transported?(response)
    JSON.parse(response.body)
  end

  def self.post(payload)
    post = Net::HTTP::Post.new(PATH)
    post.body = payload
    http.request(post)
  end

  def self.http
    http = Net::HTTP.new(HOST, PORT)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 60
    http.read_timeout = 60
    http
  end

  def self.transported?(response)
    response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  end

  private_class_method :post, :http, :transported?
end
