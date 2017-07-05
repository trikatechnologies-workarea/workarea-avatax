module Workarea
  module Pricing
    module Calculators
      # calculates order/shipping sales tax via the Avalara Avatax API
      class AvalaraTaxCalculator
        include Calculator

        def adjust
          response = Avatax::TaxRequest.new(order: order, shippings: shippings).response

          return unless response.success?

          shippings.each do |shipping|
            next unless shipping.address.present?

            price_adjustments_for(shipping).each do |adjustment|
              tax_line = response.tax_line_for_adjustment adjustment
              next unless tax_line.present?

              adjust_pricing(
                shipping,
                tax_line,
                "order_item_id" => adjustment._parent.id,
                "adjustment" => adjustment.id
               )
            end

            shipping_tax_line = response.tax_line_for_shipping(shipping)
            adjust_pricing(shipping, shipping_tax_line, "shipping_service_tax" => true)
          end
        rescue Faraday::TimeoutError => error
          handle_timeout_error(error)
        end

        private

          def handle_timeout_error(error)
            if defined?(Raven)
              Raven.capture_exception(error)
            end
          end

          # If doing split shipping (different items go to different shipping
          # addresses), decorate this method to return the proper price
          # adjustments that match the shipping. (This will have to be added to
          # the UI and saved, probably on the Shipping object)
          #
          # @return [PriceAdjustmentSet]
          #
          def price_adjustments_for(shipping)
            order.price_adjustments
          end

          def adjust_pricing(shipping, tax_line, data = {})
            return if tax_line.tax.to_m.zero?

            line_details = tax_line.details.each_with_object({}) do |detail, memo|
              memo[detail.taxName] = detail.rate
            end

            shipping.adjust_pricing(
              price: "tax",
              calculator: self.class.name,
              description: "Sales Tax",
              amount: tax_line.tax.to_m,
              data: data.merge(line_details)
            )
          end
      end
    end
  end
end
