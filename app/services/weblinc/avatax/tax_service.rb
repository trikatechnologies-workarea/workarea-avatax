module Weblinc
  module Avatax
    class TaxService

      # AvaTax::TaxService doesn't provide a good way to change settings thru initialize
      def initialize(order)
        @order = order

        settings = Weblinc::Avatax::Setting.current
        AvaTax.configure do
          account_number settings.account_number
          license_key    settings.license_key
          service_url    settings.service_url
        end
      end

      def get(options={})
         default_opts = {
          commit: false
        }
        options = default_opts.merge(options)
        response = avatax_client.get(request.as_json)

        request = Weblinc::Avatax::TaxRequest.new(
          order: @order,
          commit: options[:commit]
        )

        response = avatax_client.get(request)

        # TODO: Domain model for Response logic
        result = { status: response["ResultCode"] }

        if response["ResultCode"] == "Success"
          # separate taxed items and shipping cost
          lines_shipping = response['TaxLines'].select do |line|
            line['LineNo'] == 'SHIPPING'
          end
          lines_items = response['TaxLines'] - lines_shipping

          # gather up item price adjustments
          result[:item_adjustments] = lines_items.map do |line|
            # get the item for the line
            line_index = line['LineNo'].to_i
            item = @order.items[line_index]
            { item: item, amount: line['Tax'].to_m }
          end

          # gather shipping price adjustments
          result[:shipping_adjustments] = lines_shipping.map do |line|
            { amount: line['Tax'].to_m }
          end
        else
          log_errors('GetTax', response['Messages'])
          result[:status] = 'Errors'
          result[:errors] = result['Messages']
        end

        result
      end

      def cancel(request_hash)
        @avatax_tax_service.cancel(request_hash)
      end

      def estimate(coordinates, sale_amount)
        @avatax_tax_service.estimate(coordinates, sale_amount)
      end

      def ping
        begin  # catch exception if service URL is not valid
          ping_result = @avatax_tax_service.ping
          if ping_result["ResultCode"] == "Success"
            ret_value = {status: 'Service Available', errors: []}
          else
            ret_value = {
              status: 'Errors',
              errors: ping_result["Messages"].collect { |message| message["Summary"] }
            }
          end
        rescue NoMethodError => e   # typo in protocol httttp://
          ret_value = {status: "Exception", errors: [e.message]}
        rescue ::OpenSSL::SSL::SSLError => e   # https, valid domain name but not offering tax service
          ret_value = {status: "Exception", errors: [e.message]}
        rescue ::Errno::ETIMEDOUT => e   # https, invalid domain name 
          ret_value = {status: "Exception", errors: [e.message]}
        end
        ret_value
      end

      private

      def avatax_client
        @avatax_client ||= AvaTax::TaxService.new
      end

      def log_errors(endpoint, messages=[])
        Rails.logger.error "Avatax #{endpoint} call failed"
        messages.each do |msg|
          Rails.logger.error "Avatax: #{msg}"
        end
      end
    end
  end
end
