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

        api_response = log_time('GetTax') do
          avatax_client.get(request.as_json)
        end

        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: 'GetTax (get)'
        )
      end

      def post
        endpoint = 'GetTax (post)'
        request = Weblinc::Avatax::TaxRequest.new(
          order: @order,
          doc_type: 'SalesInvoice'
        )
        api_response = log_time(endpoint) do
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
          commit: true
        )
        api_response = log_time('GetTax (commit)') do
          avatax_client.get(request.as_json)
        end

        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          endpoint: 'GetTax (commit)'
        )
      end

      def cancel
        request = Weblinc::Avatax::CancelTaxRequest.new(order: @order)
        log_time('CancelTax') do
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

      def log_time(msg)
        time = Time.now
        value = yield
        ms_since = (Time.now - time) * 1000
        Rails.logger.info "AvaTax #{msg} completed in #{ms_since}ms"
        return value
      end
    end
  end
end
