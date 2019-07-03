module Bigcommerce
  class Config < Hashie::Mash
    DEFAULTS = {
      base_url: 'https://api.bigcommerce.com'
    }.freeze

    def api_url
      return url if auth == 'legacy'

      base = ENV.fetch('BC_API_ENDPOINT', DEFAULTS[:base_url])
      "#{base}/stores/#{store_hash}/v2"
    end
  end
end
