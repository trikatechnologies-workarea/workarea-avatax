module Weblinc
  module Avatax
    class InvoiceListener
      def weblinc_order_placed(order)
        Weblinc::Avatax::TaxService.new(order).get(commit: true)
      end
    end
  end
end
