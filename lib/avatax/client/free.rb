module AvaTax
  class Client
    module Free 


      # FREE API - Request a free trial of AvaTax
      #
      # Call this API to obtain a free AvaTax sandbox account.
      #
      # This API is free to use. No authentication credentials are required to call this API.
      # The account will grant a full trial version of AvaTax (e.g. AvaTaxPro) for a limited period of time.
      # After this introductory period, you may continue to use the free TaxRates API.
      #
      # Limitations on free trial accounts:
      #
      # * Only one free trial per company.
      # * The free trial account does not expire.
      # * Includes a limited time free trial of AvaTaxPro; after that date, the free TaxRates API will continue to work.
      # * Each free trial account must have its own valid email address.
      # @param model [Object] Required information to provision a free trial account.
      # @return [Object]
      def request_free_trial(model)
        path = "/api/v2/accounts/freetrials/request"
        post(path, model)
      end


      # FREE API - Sales tax rates for a specified address
      #
      # # Free-To-Use
      #
      # The TaxRates API is a free-to-use, no cost option for estimating sales tax rates.
      # Any customer can request a free AvaTax account and make use of the TaxRates API.
      #
      # Usage of this API is subject to rate limits. Users who exceed the rate limit will receive HTTP
      # response code 429 - `Too Many Requests`.
      #
      # This API assumes that you are selling general tangible personal property at a retail point-of-sale
      # location in the United States only.
      #
      # For more powerful tax calculation, please consider upgrading to the `CreateTransaction` API,
      # which supports features including, but not limited to:
      #
      # * Nexus declarations
      # * Taxability based on product/service type
      # * Sourcing rules affecting origin/destination states
      # * Customers who are exempt from certain taxes
      # * States that have dollar value thresholds for tax amounts
      # * Refunds for products purchased on a different date
      # * Detailed jurisdiction names and state assigned codes
      # * And more!
      #
      # Please see [Estimating Tax with REST v2](http://developer.avalara.com/blog/2016/11/04/estimating-tax-with-rest-v2/)
      # for information on how to upgrade to the full AvaTax CreateTransaction API.
      # @param line1 [String] The street address of the location.
      # @param line2 [String] The street address of the location.
      # @param line3 [String] The street address of the location.
      # @param city [String] The city name of the location.
      # @param region [String] The state or region of the location
      # @param postalCode [String] The postal code of the location.
      # @param country [String] The two letter ISO-3166 country code.
      # @return [Object]
      def tax_rates_by_address(options={})
        path = "/api/v2/taxrates/byaddress"
        get(path, options)
      end


      # FREE API - Sales tax rates for a specified country and postal code
      #
      # # Free-To-Use
      #
      # The TaxRates API is a free-to-use, no cost option for estimating sales tax rates.
      # Any customer can request a free AvaTax account and make use of the TaxRates API.
      #
      # Usage of this API is subject to rate limits. Users who exceed the rate limit will receive HTTP
      # response code 429 - `Too Many Requests`.
      #
      # This API assumes that you are selling general tangible personal property at a retail point-of-sale
      # location in the United States only.
      #
      # For more powerful tax calculation, please consider upgrading to the `CreateTransaction` API,
      # which supports features including, but not limited to:
      #
      # * Nexus declarations
      # * Taxability based on product/service type
      # * Sourcing rules affecting origin/destination states
      # * Customers who are exempt from certain taxes
      # * States that have dollar value thresholds for tax amounts
      # * Refunds for products purchased on a different date
      # * Detailed jurisdiction names and state assigned codes
      # * And more!
      #
      # Please see [Estimating Tax with REST v2](http://developer.avalara.com/blog/2016/11/04/estimating-tax-with-rest-v2/)
      # for information on how to upgrade to the full AvaTax CreateTransaction API.
      # @param country [String] The two letter ISO-3166 country code.
      # @param postalCode [String] The postal code of the location.
      # @return [Object]
      def tax_rates_by_postal_code(options={})
        path = "/api/v2/taxrates/bypostalcode"
        get(path, options)
      end

    end
  end
end