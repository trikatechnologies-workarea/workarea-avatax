module Weblinc
  module Avatax
    class TaxWorker
      include Sidekiq::Worker

      def perform(order_number)
        order = Weblinc::Order.find_by(number: order_number)
        Weblinc::Avatax::TaxService.new(order).post
      end
    end
  end
end
