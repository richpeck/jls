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
    def push_custom_fields(params)
      self.put "customers/form-field-values", params.merge({customer_id: self[:id]}) # => customer_id, name, value
    end

  end
end
