module Weblinc
  module Avatax
    class Line
      attr_accessor :item, :line_no

      def initialize(options={})
        @item = options[:item]
        @line_no = options[:line_no]
      end

      def tax_code
        # if the tax code isn't blank return it, otherwise return NT to represent
        # non-taxable items
        if price.data['tax_code'].present?
          price.data['tax_code']
        else
          'NT'
        end
      end

      def description
        item.sku_details.values.join(' ')
      end

      def amount
        (price.amount + discount_amount).to_s
      end

      def quantity
        item.quantity
      end

      def item_code
        item.sku
      end

      def price
        item.price_adjustments.detect { |adj| adj.price == "item" }
      end

      def discount_amount
        item.price_adjustments.discounts.sum(&:amount)
      end

      def to_request
        {
          # Required Parameters
          LineNo: line_no,
          ItemCode: item_code,
          Qty: quantity,
          Amount: amount,
          OriginCode: Weblinc::Avatax::TaxRequest::DEFAULT_ORIGIN_CODE,
          DestinationCode: Weblinc::Avatax::TaxRequest::DEFAULT_DEST_CODE,

          # Best Practice Request Parameters
          Description: description,
          TaxCode: tax_code
        }
      end
    end
  end
end
