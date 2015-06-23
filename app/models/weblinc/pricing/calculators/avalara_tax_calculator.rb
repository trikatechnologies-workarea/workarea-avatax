module Weblinc
  module Pricing
    module Calculators
      class AvalaraTaxCalculator
        include Calculator

        def taxable_items
          @taxable_items ||= order.items.select do |item|
            item.price_adjustments.sum > 0
          end
        end

        def shipping_total
          @shipping_total ||= order.shipping_method.price_adjustments.sum
        end

        def adjust
          return if shipments.map(&:address).compact.empty?
          return unless order.call_avatax_api_flag
          response = Weblinc::Avatax::TaxService.new(order, shipments).get

          order.items.each do |item|
            response.order_item_lines(item.id.to_s).each do |tax_line|
              item.adjust_pricing(
                price: 'tax',
                calculator: self.class.name,
                description: 'Sales Tax',
                amount: tax_line['Tax'].to_m
              )
            end
          end

          shipments.each do |shipment|
            response.shipment_lines(shipment) do |tax_line|
              shipment.adjust_pricing(
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
end
