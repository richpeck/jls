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
require 'sinatra/respond_to'
require 'sinatra/cors'

## BigCommerce ##
require 'bigcommerce'
require 'securerandom'

## Extra ##
require 'net/https' # => URL::HTTPS core (for creating URL out of naked domain)
require "addressable/uri" # => Addressable::URI (break down URL into components // for request.referrer - https://github.com/sporkmonger/addressable#example-usage)

##########################################################
##########################################################

## Integrations ##
Sinatra::Application.register Sinatra::RespondTo

##########################################################
##########################################################

## Definitions ##
## Any variables defined here ##
domain   = "jlsmobility.co.uk"
debug    = ENV.fetch("DEBUG", false) != false ## this needs to be evaluated this way because each ENV variable returns a string ##

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

## Options ##
set :show_exceptions, true if debug
set :assume_xhr_is_js, true ## respond_to

## CORS ##
## Only allow requests from domain ##
set :allow_origin,   "https://jlsmobility.co.uk"
set :allow_methods,  "POST"
set :allow_headers,  "content-type,if-modified-since"
set :expose_headers, "location,link"

##########################################################
##########################################################

## Exception Handling ##
## This allows us to manage what is seen on the site in case of an error ##
## Not really needed, but is good to work with Sinatra ##
error Bigcommerce::BadRequest do

  ## Data ##
  message = JSON.parse(env['sinatra.error'].message.to_s)
  message = message.first

  ## Status ##
  status message["status"]

  ## Response ##
  respond_to do |wants|
    wants.html { message["message"] } # => bare message
    wants.js   { message["message"] } # => bare message
  end

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

## Actions ##
## This allows us to accept inbound requests from the Internet ##
## Obviously, we also have to balance it against the
post '/' do

  ## Debug ##
  ## Allows us to test and get responses without data ##
  unless debug

    ## Vars ##
    ## Because this has to operate with "request", needs to be declared here ##
    referrer = Addressable::URI.parse(request.referrer)

    referrer 

    ## Request ##
    ## Block unauthorized domains from accessing ##
    ## This means that any referral (link clicks) that don't come from the domain are denied) ##
    ## Only requests themselves (IE NOT referrers) from the domain will be accepted ##
    halt 401, "Unauthorized Domain (#{referrer.domain})" unless referrer.domain == domain

    ## Params ##
    ## Only allow processes with certain params ##
    ## This further protects the core functionality of the app ##
    halt 400, 'Missing Params' unless params.has_key?('email') && !params[:email].empty?

  end ## debug

  ## Create customer ##
  ## This allows us to create a new customer and pass their details back to the front-end JS ##
  @customer = Bigcommerce::Customer.create(first_name: 'Karl', last_name: 'The Frog', email: "eab284fbd0@example.com")

  ## Response ##
  ## Only respond to JS (unless in debug mode) ##
  respond_to do |wants|
    wants.html { @customer.inspect() } # => views/post.html.haml, also sets content_type to text/html
    wants.js   { erb :post }           # => views/post.js.erb, also sets content_type to application/javascript
  end

end

##########################################################
##########################################################
