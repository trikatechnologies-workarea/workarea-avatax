module Weblinc
  module Avatax
    class ItemLine < Line
      attr_accessor :item

      def initialize(options={})
        @item = options.delete(:item)
        super(options)
      end

      def amount
        (code_amount + discount_amount).to_s
      end

      def description
        "#{item.product_details["name"]} #{item.sku_details.values.join(' ')}"
      end

      def item_code
        item.sku
      end

      def order_item_id
        item.id.to_s
      end

      def quantity
        item.quantity
      end

      private

      def code_amount
        code_price_adjustments.sum(&:amount)
      end

      def discount_amount
        if pricing.tax_code == @tax_code
          item.price_adjustments.discounts.sum(&:amount)
        else
          0.to_m
        end
      end

      def code_price_adjustments
        item.price_adjustments.select do |a|
          a.price == 'item' && a.data['tax_code'] == @tax_code
        end
      end

      def pricing
        @pricing ||= Weblinc::Pricing::Sku.find item.sku
      end
    end
  end
end
