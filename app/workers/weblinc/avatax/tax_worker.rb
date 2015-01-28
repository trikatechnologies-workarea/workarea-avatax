module Weblinc
  module Avatax
    class TaxWorker
      include Sidekiq::Worker

      def perform(order_number)
        settings = Weblinc::Avatax::Setting.current
        unless settings.doc_handling == :none
          order = Weblinc::Order.find_by(number: order_number)
          svc = Weblinc::Avatax::TaxService.new(order)

          if settings.doc_handling == :commit
            svc.commit
          else
            svc.post
          end
        end
      end
    end
  end
end
