module Weblinc
  module Avatax
    class InvoiceListener
      def weblinc_order_placed(order)
        Weblinc::Avatax::TaxWorker.perform_async(order.number)
      end
    end
  end
end
