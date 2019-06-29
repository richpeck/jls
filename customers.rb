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

## BigCommerce ##
require 'bigcommerce'
require 'securerandom'

##########################################################
##########################################################

## Integrations ##
Sinatra::Application.register Sinatra::RespondTo

##########################################################
##########################################################

## Definitions ##
## Any variables defined here ##
domain = "jlsmobility.co.uk"
debug  = ENV.fetch("DEBUG", false) != false ## this needs to be evaluated this way because each ENV variable returns a string ##

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

##########################################################
##########################################################

## Exception Handling ##
error Bigcommerce::BadRequest do
  message = JSON.parse(env['sinatra.error'].message)
  message.has_key?("status") 
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
get '/' do

  ## Debug ##
  ## Allows us to test and get responses without data ##
  unless debug

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
  @customer = Bigcommerce::Customer.create(first_name: 'Karl', last_name: 'The Frog', email: "eab284fbd0@example.com")

  ## Response ##
  ## Only respond to JS (unless in debug mode) ##
  respond_to do |wants|
    wants.html    { @customer.inspect() } # => views/post.html.haml, also sets content_type to text/html
    wants.xml     { @post.to_xml }        # => sets content_type to application/xml
    wants.js      { erb :post }           # => views/post.js.erb, also sets content_type to application/javascript
  end

end

##########################################################
##########################################################
