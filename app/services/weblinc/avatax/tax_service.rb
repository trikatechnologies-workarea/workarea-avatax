module Weblinc
  module Avatax
    class TaxService

      # AvaTax::TaxService doesn't provide a good way to change settings thru initialize
      def initialize(order=nil)
        @order = order

        settings = Weblinc::Avatax::Setting.current
        AvaTax.configure do
          account_number settings.account_number
          license_key    settings.license_key
          service_url    settings.service_url
        end
      end

      def get(options={})
        request = Weblinc::Avatax::TaxRequest.new(order: @order)
        api_response = avatax_client.get(request.as_json)
        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: 'GetTax (get)'
        )
      end

      def commit
        request = Weblinc::Avatax::TaxRequest.new(order: @order)
        api_response = avatax_client.get(request.as_json)
        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: 'GetTax (commit)'
        )
      end

      def cancel(request_hash)
        @avatax_tax_service.cancel(request_hash)
      end

      def estimate(coordinates, sale_amount)
        @avatax_tax_service.estimate(coordinates, sale_amount)
      end

      def ping
        begin  # catch exception if service URL is not valid
          api_result = avatax_client.ping
        rescue NoMethodError, ::OpenSSL::SSL::SSLError, ::Errno::ETIMEDOUT => e
          # NoMethodError => typo in protocol ex httttttp://
          # SSLError => https, valid domain name but not offering tax service
          # ETIMEDOUT => https, invalid domain name

          # fake api response with exception message and backtrace
          api_result = {
            'StatusCode' => 'Exception',
            'Messages' => [e.message, e.backtrace]
          }
        end

        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_result,
          endpoint: 'EstimateTax (ping)'
        )
      end

      private

      def avatax_client
        @avatax_client ||= AvaTax::TaxService.new
      end
    end
  end
end
