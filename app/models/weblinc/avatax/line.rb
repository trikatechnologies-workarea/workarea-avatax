module Weblinc
  module Avatax
    class Line
      attr_accessor :item, :tax_code

      def initialize(options={})
        @item = options[:item]
        @index = options[:index]
        @tax_code = options[:tax_code]
      end

      def description
        item.sku_details.values.join(' ')
      end

      def amount
        (code_amount + discount_amount).to_s
      end

      def quantity
        item.quantity
      end

      def item_code
        item.sku
      end

      def line_no
        "#{@index}-#{item.sku}"
      end

      def code_adjustments
        item.price_adjustments.select do |adj|
          adj.data['tax_code'] == self.tax_code
        end
      end

      def code_amount
        code_adjustments.sum(&:amount)
      end

      def discount_amount
        item.price_adjustments.discounts.sum(&:amount)
      end

      def pricing
        @pricing ||= Weblinc::Pricing::Sku.find item.sku
      end

      def as_json
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
