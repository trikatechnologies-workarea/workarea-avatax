module Weblinc
  module Avatax
    class ShippingLine < Line
      attr_accessor :shipment

      def initialize(options={})
        @shipment = options.delete(:shipment)
        super(options)
      end

      def amount
        shipment
          .price_adjustments
          .select { |adj| adj.price == 'shipping' }
          .sum(&:amount)
          .to_s
      end

      def description
        shipment.shipping_method.name
      end

      def item_code
        'SHIPPING'
      end

      def quantity
        1
      end

      def shipment_id
        shipment.id
      end
    end
  end
end
