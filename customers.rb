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

## Actions ##
## This allows us to accept inbound requests from the Internet ##
## Obviously, we also have to balance it against the
get '/' do

  ## Debug ##
  ## Allows us to test and get responses without data ##
  if !ENV["DEBUG"]

    ## Request ##
    ## Block unauthorized domains from accessing ##
    ## This means that any referral (link clicks) that don't come from the domain are denied) ##
    ## Only requests themselves (IE NOT referrers) from the domain will be accepted ##
    halt 401, 'Unauthorized Domain' unless request.host == domain

    ## Params ##
    ## Only allow processes with certain params ##
    ## This further protects the core functionality of the app ##
    halt 401, 'Unauthorized PArams' unless params && params.has_key?('email')

  end ## debug

  ## Create customer ##
  ## This allows us to create a new customer and pass their details back to the front-end JS ##
  begin
    @customer = Bigcommerce::Customer.create(
      first_name: 'Karl',
      last_name: 'The Frog',
      email: "eab284fbd0@example.com"
    )
  rescue Bigcommerce::BadRequest => e
      return "Error"
  end

  @customer.inspect()
  #@customer.status == 200 ? "#{@customer.email} created successfully" : "error"

end

##########################################################
##########################################################



##########################################################
##########################################################
