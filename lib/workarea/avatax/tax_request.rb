module Workarea
  module Avatax
    class TaxRequest
      attr_reader :order, :shippings, :options

      def initialize(order:, shippings: [], **options)
        @order = order
        @shippings = shippings
        @options = options.deep_symbolize_keys
      end

      def response
        @response ||= Response.new(
          response: Avatax.gateway.create_transaction(request_body),
          request_order_line_items: order_line_items,
          request_shipping_line_items: shipping_line_items
        )
      end

      private

        def request_body
          {
            type:              type,
            date:              date,
            code:              order.id.to_s,
            customerCode:      customer_code,
            customerUsageType: customer_usage_type,
            addresses:         addresses.hash,
            commit:            commit,
            lines:             lines.map(&:hash)
          }
        end

        def addresses
          Addresses.new(tax_request: self)
        end

        def date
          DateTime.now.iso8601
        end

        def type
          options[:type] || "SalesOrder"
        end

        def commit
          options[:commit] || false
        end

        def customer_code
          return "" unless order.email.present?

          order.email.truncate(50, omission: "")
        end

        def customer_usage_type
          return "" unless order.email.present?

          User.find_by_email(order.email).try(:customer_usage_type)
        end

        # combined order item and shipping lines with sequential numbering applied
        def lines
          (order_line_items + shipping_line_items).map.with_index(1) do |line_item, index|
            line_item.tap { |li| li.line_number = index }
          end
        end

        def order_line_items
          @order_line_items ||= order_price_adjustments.grouped_by_parent.flat_map do |item, set|
            set.map do |adjustment|
              next unless adjustment.data["tax_code"].present?

              OrderLineItem.new(order_item: item, adjustment: adjustment, adjustment_set: set)
            end
          end.compact
        end

        def order_price_adjustments
          order.price_adjustments
        end

        def shipping_line_items
          @shipping_line_item ||= shippings.map { |shipping| ShippingLineItem.new(shipping: shipping) }
        end
    end
  end
end
