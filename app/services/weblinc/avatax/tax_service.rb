module Weblinc
  module Avatax
    class TaxService
      # AvaTax::TaxService doesn't provide a good way to change settings thru initialize
      def initialize(order)
        @order = order
        settings = avatax_settings

        AvaTax.configure do
          account_number settings.account_number
          license_key    settings.license_key
          service_url    settings.service_url
        end
      end

      def get(options = {})
        default_opts = {
          commit: false
        }
        options = default_opts.merge(options)

        request = get_tax_request(options[:commit])
        response = avatax_tax_service.get(request)

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

      def avatax_settings
        @avatax_settings ||= Weblinc::Avatax::Setting.current
      end

      def avatax_tax_service
        @avatax_tax_service ||= AvaTax::TaxService.new
      end

      def get_tax_request(is_commit=false)
        if @get_request.blank?
          cust_code = @order.email || "TEMPORARY"
          @get_request = {
            CustomerCode: cust_code.truncate(50, omission: ''),
            DocType:  is_commit ? "PurchaseInvoice" : "PurchaseOrder",
            Commit:  is_commit,
            DocDate: Time.now.strftime("%Y-%m-%d"),
            CompanyCode:  avatax_settings.company_code,
            Client:  "WEBLINC #{Weblinc::VERSION::STRING} AVATAX #{Weblinc::Avatax::VERSION}",
            DocCode:  "ORDER-#{@order.number}",
            DetailLevel:  "Tax",
            Addresses:  [ distribution_address, shipping_address ],
            Lines:  item_lines.push(shipping_line).as_json
          }
          if user.exemption_no.present?
            @get_request[:ExemptionNo] = user.exemption_no
          end

          if user.customer_usage_type.present?
            @get_request[:CustomerUsageType] = user.customer_usage_type
          end
        end

        pp @get_request
        @get_request
      end

      def item_lines
        @lines ||= @order.items.flat_map.with_index do |item, index|
          Weblinc::Avatax::LineFactory.make_item_lines(item, index)
        end
      end

      def shipping_line
        shipping_total = @order.shipping_method.price_adjustments.sum

        {
          LineNo: "SHIPPING",
          ItemCode: "SHIPPING",
          Description: @order.shipping_method.name,
          Qty: 1,
          Amount: shipping_total.to_s,
          OriginCode: Weblinc::Avatax::DEFAULT_ORIGIN_CODE,
          DestinationCode: Weblinc::Avatax::DEFAULT_DEST_CODE
        }
      end

      def distribution_address
        dist_center = { AddressCode: Weblinc::Avatax::DEFAULT_ORIGIN_CODE }
        dist_center.merge(Weblinc::Avatax.config.dist_center)
      end

      def shipping_address
        {
          AddressCode: Weblinc::Avatax::DEFAULT_DEST_CODE,
          Line1: @order.shipping_address.street,
          Line2: @order.shipping_address.street_2,
          City: @order.shipping_address.city,
          Region: @order.shipping_address.region,
          Country: @order.shipping_address.country,
          PostalCode: @order.shipping_address.postal_code
        }
      end

      def user
        @user ||= Weblinc::User.find_by(email: @order.email)
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
