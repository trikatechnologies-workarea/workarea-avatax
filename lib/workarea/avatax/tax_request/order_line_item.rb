module Workarea
  module Avatax
    class TaxRequest::OrderLineItem < TaxRequest::LineItem
      attr_reader :order_item, :adjustment

      def initialize(order_item:, adjustment:, adjustment_set:)
        @order_item = order_item
        @adjustment = adjustment
        @adjustment_set = adjustment_set
      end

      private

        def quantity
          adjustment.quantity
        end

        def amount
          @adjustment_set.taxable_share_for adjustment
        end

        def item_code
          order_item.sku
        end

        def tax_code
          adjustment.data["tax_code"]
        end

        def product
          @product ||= Mongoid::Factory.from_db(
            Catalog::Product,
            order_item.product_attributes
          )
        end

        def description
          return if order_item.product_attributes.empty?
          product.name
        end
    end
  end
end
