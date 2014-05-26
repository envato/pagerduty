# encoding: utf-8
require 'json'
require 'net/http'
require 'net/https'

# @api private
module Pagerduty::HttpTransport
  extend self

  HOST = "events.pagerduty.com"
  PORT = 443
  PATH = "/generic/2010-04-15/create_event.json"

  def send(payload = {})
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
    http = Net::HTTP.new(HOST, PORT)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 60
    http.read_timeout = 60
    http
  end

  def transported?(response)
    response.kind_of? Net::HTTPSuccess or response.kind_of? Net::HTTPRedirection
  end
end
