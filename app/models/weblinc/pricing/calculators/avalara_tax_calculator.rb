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
          return unless order.shipping_address.present?
          result = Weblinc::Avatax::TaxService.new(order).get

          result[:item_adjustments].each do |adj|
            adj[:item].adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Sales Tax',
              amount: adj[:amount]
            )
          end

          result[:shipping_adjustments].each do |adj|
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
