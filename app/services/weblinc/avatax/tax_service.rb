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

      def get
        request = Weblinc::Avatax::TaxRequest.new(order: @order)
        endpoint = 'GetTax (get)'

        api_response = log(request, endpoint) do
          avatax_client.get(request.as_json)
        end

        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: 'GetTax (get)'
        )
      end

      def post
        request = Weblinc::Avatax::TaxRequest.new(
          order: @order,
          doc_type: 'SalesInvoice'
        )
        endpoint = 'GetTax (post)'

        api_response = log(request, endpoint) do
          avatax_client.get(request.as_json)
        end

        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: endpoint
        )
      end

      def commit
        request = Weblinc::Avatax::TaxRequest.new(
          order: @order,
          doc_type: 'SalesInvoice',
          commit: true
        )
        endpoint = 'GetTax (commit)'

        api_response = log(endpoint, request) do
          avatax_client.get(request.as_json)
        end

        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: endpoint
        )
      end

      def cancel
        request = Weblinc::Avatax::CancelTaxRequest.new(order: @order)
        endpoint = 'CancelTax (cancel)'
        log(request, endpoint) do
          avatax_client.cancel(request.as_json)
        end
      end

      def estimate(coordinates, sale_amount)
        avatax_client.estimate(coordinates, sale_amount)
      end

      def ping
        begin  # catch exception if service URL is not valid
          api_result = avatax_client.ping
        rescue NoMethodError, ::OpenSSL::SSL::SSLError, ::Errno::ETIMEDOUT => e
          # avatax client ping method doesn't really deal well with bad domain
          # settings, so we catch some exceptions to handle them a little better
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

      def log(request, msg)
        time = Time.now
        block_return = yield
        ms_since = (Time.now - time) * 1000

        Rails.logger.info "AvaTax #{msg} completed in #{ms_since}ms"
        Rails.logger.info "AvaTax Request: #{request.as_json}"

        return block_return
      end
    end
  end
end
