module Weblinc
  module Avatax
    class InvoiceListener
      def weblinc_order_placed(order)
        Weblinc::Avatax::TaxService.new(order).commit
      end
    end
  end
end
