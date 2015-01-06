module Weblinc
  module Avatax
    class Line
      attr_accessor :item

      def initialize(options={})
        @item = options[:item]
        @adjustment = options[:adjustment]
        @share = options[:share] || 1

        @line_no = options[:line_no]
      end

      def tax_code
        # if the tax code isn't blank return it, otherwise return NT to represent
        # non-taxable items
        if @adjustment.data['tax_code'].present?
          @adjustment.data['tax_code']
        else
          'NT'
        end
      end

      def description
        @item.sku_details.values.join(' ')
      end

      def amount
        @adjustment.amount
      end

      def share_amount
        amount * @share
      end

      def to_request
        {
          # Required Parameters
          LineNo: @line_no,
          ItemCode: @item.sku,
          Qty: @item.quantity,
          Amount: share_amount.to_s,
          OriginCode: Weblinc::Avatax::DEFAULT_ORIGIN_CODE,
          DestinationCode: Weblinc::Avatax::DEFAULT_DEST_CODE,

          # Best Practice Request Parameters
          Description: description,
          TaxCode: tax_code
        }
      end
    end
  end
end
