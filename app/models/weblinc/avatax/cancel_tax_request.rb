module Weblinc
  module Avatax
    class CancelTaxRequest < TaxRequest
      attr_accessor :cancel_code

      def initialize(options = {})
        super(options)
        @cancel_code = options[:cancel_code]
      end

      def doc_type
        "PurchaseInvoice"
      end

      def as_json
        {
          CompanyCode: settings.company_code,
          DocType: doc_type,
          DocCode: doc_code,
          CancelCode: cancel_code
        }
      end
    end
  end
end
