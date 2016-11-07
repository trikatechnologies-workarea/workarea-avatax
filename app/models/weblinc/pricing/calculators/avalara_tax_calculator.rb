module Weblinc
  module Pricing
    module Calculators
      # calculates order/shipment sales tax via the Avalara Avatax API
      class AvalaraTaxCalculator
        include Calculator

        def adjust
          return unless has_shipments?
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

        # CheckoutsController#setup_view_models sets flag to true during the address step
        # if the cart entered checkout previously it will still have a shipment address with
        # only region, country and zip. This could cause people to see tax calculated in
        # the order total on the address step but show TBD on the tax line.
        def has_shipments?
          return false if shipments.map(&:address).compact.empty? ||
            shipments.map(&:address).map(&:street).compact.empty?
          true
        end
      end
    end
  end
end
