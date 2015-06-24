module Weblinc
  module Pricing
    module Calculators
      # calculates order/shipment sales tax via the Avalara Avatax API
      class AvalaraTaxCalculator
        include Calculator

        def adjust
          return if shipments.map(&:address).compact.empty?
          return unless order.call_avatax_api_flag
          response = Weblinc::Avatax::TaxService.new(order, shipments).get

          adjust_items(response)
          adjust_shipments(response)
        end

        private

        def adjust_items(response)
          order.items.each do |item|
            lines = response.order_item_lines(item.id.to_s)
            adjust_pricing(item, lines)
          end
        end

        def adjust_shipments(response)
          shipments.each do |shipment|
            lines = response.shipment_lines(shipment.id.to_s)
            adjust_pricing(shipment, lines)
          end
        end

        # takes a shipment or order item and applies the tax lines found in
        # response from the Avatax API
        def adjust_pricing(taxable, lines)
          lines.each do |tax_line|
            taxable.adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Sales Tax',
              amount: tax_line['Tax'].to_m
            )
          end
        end
      end
    end
  end
end
