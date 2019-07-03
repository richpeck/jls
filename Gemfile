###########################################
###########################################
##   _____                 __ _ _        ##
##  |  __ \               / _(_) |       ##
##  | |  \/ ___ _ __ ___ | |_ _| | ___   ##
##  | | __ / _ \ '_ ` _ \|  _| | |/ _ \  ##
##  | |_\ \  __/ | | | | | | | | |  __/  ##
##  \_____/\___|_| |_| |_|_| |_|_|\___|  ##
##                                       ##
###########################################
###########################################

# => Sources
source 'https://rubygems.org'

###########################################
###########################################

# => Ruby
# => https://github.com/cantino/huginn/blob/master/Gemfile#L4
ruby [RUBY_VERSION, '2.6.3'].min

###########################################
###########################################

# => Sinatra
gem 'sinatra' ## base gem
gem 'sinatra-respond_to', '~> 0.9.0' ## filter response based on request type
gem 'sinatra-cors', '~> 1.1' ## protect app via CORS

# => Extras
gem 'addressable', '~> 2.6' ## break down the various components of a domain
gem 'bigcommerce', path: 'bigcommerce-1.0.1' ## BigCommerce API wrapper -- local version has changed /resources/customers/customer.rb to allow us to change the "redirect_to" value for customer_login

###########################################
###########################################
