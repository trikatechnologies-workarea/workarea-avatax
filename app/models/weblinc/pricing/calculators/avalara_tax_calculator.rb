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
          return unless order.call_avatax_api_flag
          response = Weblinc::Avatax::TaxService.new(order).get

          response.item_adjustments.each do |adj|
            item = order.items.detect { |i| i.sku == adj[:sku] }
            item.adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Sales Tax',
              amount: adj[:amount]
            )
          end

          response.shipping_adjustments.each do |adj|
            order.shipping_method.adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Sales Tax',
              amount: adj[:amount]
            )
          end
        end
      end
    end
  end
end
