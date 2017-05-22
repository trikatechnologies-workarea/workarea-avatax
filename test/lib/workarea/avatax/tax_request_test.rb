require "test_helper"

module Workarea
  module Avatax
    class TaxRequestTest < Workarea::TestCase
      setup :configure_sandbox
      teardown :reset_avatax_config

      def test_successful_response
        response = VCR.use_cassette :succesful_avatax_create_transaction do
          TaxRequest.new(order: order, shippings: shippings).response
        end

        assert response.success?
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
            config.username = "epigeon@weblinc.com"
            config.password = "648B0A9851"
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
