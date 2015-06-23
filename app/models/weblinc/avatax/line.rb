module Weblinc
  module Avatax
    class Line
      attr_accessor :line_no, :tax_code

      def initialize(options={})
        @tax_code = options[:tax_code]
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
