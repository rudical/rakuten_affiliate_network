require "httparty"

module LinkshareAPI
  # For implementation details please visit
  # https://rakutenlinkshare.zendesk.com/hc/en-us/articles/200919909-Using-the-Coupon-Web-Service
  class GetApprovedMerchants
    include HTTParty

    attr_reader :api_base_url, :api_timeout, :token

    def initialize
      @token        = LinkshareAPI.token
      @api_base_url = LinkshareAPI::WEB_SERVICE_URIS[:get_approved_merchants]
      @api_timeout  = LinkshareAPI.api_timeout

      if @token.nil?
        raise AuthenticationError.new(
          "No token. Set your token by using 'LinkshareAPI.token = <TOKEN>'. " +
          "You can retrieve your token from LinkhShare's Web Services page under the Links tab. " +
          "See https://rakutenlinkshare.zendesk.com/hc/en-us/articles/200992487-What-is-a-Web-Services-Token-Feed-Token- for details."
        )
      end

      self.class.default_timeout @api_timeout
    end

    def query(params)
      raise ArgumentError, "Hash expected, got #{params.class} instead" unless params.is_a?(Hash)
      params.merge!(token: token)
      url = api_base_url + '/' + params[:token] + '/approved'
      begin
        response = self.class.get(
          url
        )
      rescue Timeout::Error, Net::OpenTimeout
        raise ConnectionError.new("Timeout error (#{api_timeout}s)")
      end

      if response.code != 200
        raise Error.new(response.message, response.code)
      end
      error = response["fault"]
      raise InvalidRequestError.new(error["errorstring"], error["errorcode"].to_i) if error

      Response.new(response, :get_approved_merchants)
    end
  end
end
