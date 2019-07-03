require 'jwt'
require 'securerandom'

# Customer
# Identity and account details for customers shopping at a Bigcommerce store.
# https://developer.bigcommerce.com/api/stores/v2/customers

module Bigcommerce
  class Customer < Resource
    include Bigcommerce::ResourceActions.new uri: 'customers/%d'

    property :id
    property :_authentication
    property :count
    property :company
    property :first_name
    property :last_name
    property :email
    property :phone
    property :date_created
    property :date_modified
    property :store_credit
    property :registration_ip_address
    property :customer_group_id
    property :notes
    property :addresses
    property :tax_exempt_category
    property :accepts_marketing

    def self.count(params = {})
      get 'customers/count', params
    end

    # Generate a token that can be used to log the customer into the storefront.
    # This requires your app to have the store_v2_customers_login scope and to
    # be installed in the store.
    def login_token(config: Bigcommerce.config)
      payload = {
        'iss' => config.client_id,
        'iat' => Time.now.to_i,
        'jti' => SecureRandom.uuid,
        'operation' => 'customer_login',
        'store_hash' => config.store_hash,
        'customer_id' => id,
        'redirect_to' => '/checkout.php'
      }

      JWT.encode(payload, config.client_secret, 'HS256')
    end

    # RPECK 03/07/2019
    # Gives us ability to upsert customer form_fields -- https://developer.bigcommerce.com/api-reference/customer-subscribers/v3-customers-api/customer-form-fields/customerformfieldvalueput
    # This is used after we've created or invoked a customer, and allows us to push updated information about their custom preferences
    # Only accepts "name" / "value" with customer ID. If we have customer ID already, just means we have to send name/value data
    def push_custom_fields(params = {})

      ## Declaration ##
      ## This allows us declare variables etc ##
      new_params = []

      ## Need to build custom fields ##
      ## As system only accepts {"name": x, "value": y}, we need to change any of the sent items ##
      params.each_pair do |name,value|
        new_params.push({"customer_id": self[:id], "name": name, "value": value})
      end

      ## Send the payload ##
      ## Because this is V3, we need to make sure we're sending the correct data structure ##
      self.class.put "customers/form-field-values", new_params, true # => sends to v3

    end

  end
end
