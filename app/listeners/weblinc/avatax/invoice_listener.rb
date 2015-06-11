module Weblinc
  module Avatax
    class InvoiceListener
      extend Listener
      class << self
        def weblinc_order_placed(payload)
          settings = Weblinc::Avatax::Setting.current
          unless settings.doc_handling == :none
            order = Weblinc::Order.find_by(number: payload['number'])
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
end
