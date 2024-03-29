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
domain   = ENV.fetch('DOMAIN', 'jlsmobility.co.uk') ## used for CORS and other funtionality -- ENV var gives flexibility
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
#set :show_exceptions, true if debug
set :assume_xhr_is_js, true ## respond_to
set :logger, Logger.new(STDOUT) ## logger

## CORS ##
## Only allow requests from domain ##
set :allow_origin,   URI::HTTPS.build(host: domain).to_s
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
    wants.html { message["details"]["invalid_reason"] } # => bare message
    wants.js   { message["message"] } # => bare message
  end

end

##########################################################
##########################################################
##                _____           _                     ##
##               /  __ \         | |                    ##
##               | /  \/ ___   __| | ___                ##
##               | |    / _ \ / _` |/ _ \               ##
##               | \__/\ (_) | (_| |  __/               ##
##               \_____/\___/ \__,_|\___|               ##
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
  @customer = Bigcommerce::Customer.create(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], customer_group_id: 2)

  ## Custom Fields ##
  ## If custom fields are present, send them to the server ##
  ## This is entirely dependent on the correct fields being present etc ##
  @customer.push_custom_fields params[:custom_fields] if params.has_key?('custom_fields') ## should look for keys other than first_name, last_name, email

  ## Response ##
  ## Only respond to JS (unless in debug mode) ##
  respond_to do |wants|
    wants.html { @customer.login_token } # => views/post.html.haml, also sets content_type to text/html
    wants.js   { @customer.login_token } # => views/post.js.erb, also sets content_type to application/javascript
  end

end

##########################################################
##########################################################
