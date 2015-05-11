module Weblinc
  module Avatax
    class TaxService
      attr_reader :order, :shipments
      # AvaTax::TaxService doesn't provide a good way to change settings thru initialize
      def initialize(order, shipments=nil)
        @order = order
        @shipments = shipments || Weblinc::Shipping::Shipment.where(number: order.number)
        @user = Weblinc::User.where(email: order.email).first

        settings = Weblinc::Avatax::Setting.current
        AvaTax.configure do
          account_number settings.account_number
          license_key    settings.license_key
          service_url    settings.service_url
        end
      end

      def get
        request = Weblinc::Avatax::TaxRequest.new(@order, @shipments, user: @user)
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
        request = Weblinc::Avatax::TaxRequest.new(@order, @shipments,
          user: @user,
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
        request = Weblinc::Avatax::TaxRequest.new(@order, @shipments,
          user: @user,
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

      def self.ping
        settings = Weblinc::Avatax::Setting.current
        AvaTax.configure do
          account_number settings.account_number
          license_key    settings.license_key
          service_url    settings.service_url
        end
        ping_client = AvaTax::TaxService.new

        begin  # catch exception if service URL is not valid
          api_result = ping_client.ping
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
        Rails.logger.info "Avatax Response: #{block_return}"
        return block_return
      end
    end
  end
end
