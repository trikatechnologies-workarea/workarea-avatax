module Weblinc
  module Avatax
    class Line
      attr_accessor :item

      def initialize(options={})
        @item = options[:item]
        @index = options[:index]
        @tax_code = options[:tax_code]
      end

      def description
        "#{item.product_details["name"]}  #{item.sku_details.values.join(' ')}"
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
        "#{item.sku}-#{tax_code}"
      end

      def code_amount
        code_price_adjustments.sum(&:amount)
      end

      def code_price_adjustments
        item.price_adjustments.select do |a|
          a.price == 'item' && a.data['tax_code'] == @tax_code
        end
      end

      def discount_amount
        if pricing.tax_code == @tax_code
          item.price_adjustments.discounts.sum(&:amount)
        else
          0.to_m
        end
      end

      def tax_code
        @tax_code.present? ? @tax_code : 'NT'
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
          TaxCode: tax_code.present? ? tax_code : 'NT'
        }
      end
    end
  end
end
