require 'rubygems'
require 'bundler/setup'
require 'curl'

class PagerdutyException < Exception
  attr_reader :pagerduty_instance, :api_response
  
  def initialize(instance, resp)
    @pagerduty_instance = instance
    @api_response = resp
  end
end

class Pagerduty
  
  attr_reader :service_key, :incident_key
  
  def initialize(service_key, incident_key = nil)
    @service_key = service_key
    @incident_key = incident_key
  end
  
  def trigger(description, details = {})
    resp = api_call("trigger", description, details = {})
    throw PagerdutyException.new(self, resp) unless resp["status"] == "success"
    
    PagerdutyIncident.new @service_key, resp["incident_key"]
  end
  
  def get_incident(incident_key)
    PagerdutyIncident.new @service_key, incident_key
  end
  
protected
  def api_call(event_type, description, details = {})
    params = { :event_type => event_type, :service_key => @service_key, :description => description, :details => details }
    params.merge!({ :incident_key => @incident_key }) unless @incident_key == nil
    
    curl = Curl::Easy.new
    curl.url = "http://events.pagerduty.com/generic/2010-04-15/create_event.json"
    curl.http_post JSON.generate(params)
    JSON.parse curl.body_str
  end
  
end

class PagerdutyIncident < Pagerduty
  
  def initialize(service_key, incident_key)
    super service_key
    @incident_key = incident_key
  end
  
  def acknowledge(description, details = {})
    resp = api_call("acknowledge", description, details = {})
    throw PagerdutyException.new(self, resp) unless resp["status"] == "success"
    
    self
  end
  
  def resolve(description, details = {})
    resp = api_call("resolve", description, details = {})
    throw PagerdutyException.new(self, resp) unless resp["status"] == "success"
    
    self
  end
  
end
