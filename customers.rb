##########################################################
##########################################################
##   _____           _                                  ##
##  /  __ \         | |                                 ##
##  | /  \/_   _ ___| |_ ___  _ __ ___   ___ _ __ ___   ##
##  | |   | | | / __| __/ _ \| '_ ` _ \ / _ \ '__/ __|  ##
##  | \__/\ |_| \__ \ || (_) | | | | | |  __/ |  \__ \  ##
##   \____/\__,_|___/\__\___/|_| |_| |_|\___|_|  |___/  ##
##                                                      ##
##########################################################
##########################################################

## Sinatra ##
require 'sinatra'

## BigCommerce ##
require 'bigcommerce'
require 'securerandom'

##########################################################
##########################################################

## Definitions ##
## Any variables defined here ##
domain = "jlsmobility.co.uk"

## Config ##
## Allows us to configure the BigCommerce plugin to use the appropriate store data ##
Bigcommerce.configure do |config|
  config.store_hash    = ENV.fetch("STORE_HASH") ## ENV.fetch raises exception on nil
  config.client_id     = ENV.fetch("CLIENT_ID")
  config.client_secret = ENV.fetch("CLIENT_SECRET")
  config.access_token  = ENV.fetch("ACCESS_TOKEN")
end

##########################################################
##########################################################
##                  _     _ _                           ##
##                 | |   (_) |                          ##
##                 | |    _| |__  ___                   ##
##                 | |   | | '_ \/ __|                  ##
##                 | |___| | |_) \__ \                  ##
##                 \_____/_|_.__/|___/                  ##
##                                                      ##
##########################################################
##########################################################

## Exception Management ##
## Allows us to capture the errors raised by BC ##
## https://github.com/bigcommerce/bigcommerce-api-ruby/blob/master/examples/exception_handling.rb ##
def bc_handle_exception
  yield
rescue Bigcommerce::BadRequest => e
  return @customer = e
rescue Bigcommerce::Unauthorized => e
  return @customer = e
rescue Bigcommerce::Forbidden => e
  return @customer = e
rescue Bigcommerce::NotFound => e
  return @customer = e
rescue Bigcommerce::MethodNotAllowed => e
  return @customer = e
rescue Bigcommerce::NotAccepted => e
  return @customer = e
rescue Bigcommerce::TimeOut => e
  return @customer = e
rescue Bigcommerce::ResourceConflict => e
  return @customer = e
rescue Bigcommerce::TooManyRequests => e
  return @customer = e
rescue Bigcommerce::InternalServerError => e
  return @customer = e
rescue Bigcommerce::BadGateway => e
  return @customer = e
rescue Bigcommerce::ServiceUnavailable => e
  return @customer = e
rescue Bigcommerce::GatewayTimeout => e
  return @customer = e
rescue Bigcommerce::BandwidthLimitExceeded => e
  return @customer = e
rescue StandardError => e
  return "Some other Error #{e.inspect}"
end

##########################################################
##########################################################

## Actions ##
## This allows us to accept inbound requests from the Internet ##
## Obviously, we also have to balance it against the
get '/' do

  ## Debug ##
  ## Allows us to test and get responses without data ##
  if ENV.fetch("DEBUG", false) == false ## this needs to be evaluated this way because each ENV variable returns a string ##

    ## Request ##
    ## Block unauthorized domains from accessing ##
    ## This means that any referral (link clicks) that don't come from the domain are denied) ##
    ## Only requests themselves (IE NOT referrers) from the domain will be accepted ##
    halt 401, 'Unauthorized Domain' unless request.host == domain

    ## Params ##
    ## Only allow processes with certain params ##
    ## This further protects the core functionality of the app ##
    halt 401, 'Unauthorized Params' unless params && params.has_key?('email')

  end ## debug

  ## Create customer ##
  ## This allows us to create a new customer and pass their details back to the front-end JS ##
  #@customer = Bigcommerce::Customer.create(first_name: 'Karl', last_name: 'The Frog', email: "eab284fbd0@example.com")
  #@customer.inspect()
  #@customer.status == 200 ? "#{@customer.email} created successfully" : "error"

  def bc_handle_exception
    @customer = Bigcommerce::Customer.create(first_name: 'Karl', last_name: 'The Frog', email: "eab284fbd0@example.com")
  rescue Bigcommerce::BadRequest => e
    e.inspect()
  rescue Bigcommerce::Unauthorized => e
    e.inspect()
  rescue Bigcommerce::Forbidden => e
    e.inspect()
  rescue Bigcommerce::NotFound => e
    e.inspect()
  rescue Bigcommerce::MethodNotAllowed => e
    e.inspect()
  rescue Bigcommerce::NotAccepted => e
    e.inspect()
  rescue Bigcommerce::TimeOut => e
    e.inspect()
  rescue Bigcommerce::ResourceConflict => e
    e.inspect()
  rescue Bigcommerce::TooManyRequests => e
    e.inspect()
  rescue Bigcommerce::InternalServerError => e
    e.inspect()
  rescue Bigcommerce::BadGateway => e
    e.inspect()
  rescue Bigcommerce::ServiceUnavailable => e
    e.inspect()
  rescue Bigcommerce::GatewayTimeout => e
    e.inspect()
  rescue Bigcommerce::BandwidthLimitExceeded => e
    e.inspect()
  rescue StandardError => e
    return "Some other Error #{e.inspect}"
  end

end

##########################################################
##########################################################



##########################################################
##########################################################
