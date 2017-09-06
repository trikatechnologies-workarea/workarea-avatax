require "test_helper"

module Workarea
  module Avatax
    class TaxRequestTest < Workarea::TestCase
      def test_successful_response
        configure_sandbox

        request = TaxRequest.new(order: order, shippings: shippings)

        response = VCR.use_cassette :succesful_avatax_create_transaction do
          request.response
        end

        assert response.success?
      ensure
        reset_avatax_config
      end

      private

        def order
          @order ||= create_checkout_order(email: "epigeon@weblinc.com")
        end

        def shippings
          @shippings ||= Shipping.where(order_id: order.id)
        end

        def configure_sandbox
          AvaTax.configure do |config|
            config.endpoint = "https://sandbox-rest.avatax.com/"
            config.username = "jyucis-lp-avatax@weblinc.com"
            config.password = "Jm{m3NX.Q"
          end

          Avatax.gateway = ::AvaTax.client
        end

        def reset_avatax_config
          AvaTax.reset
          Avatax.gateway = Avatax::BogusGateway.new
        end
    end
  end
end
