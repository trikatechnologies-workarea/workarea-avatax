require 'spec_helper'

module Weblinc
  describe 'updating shipping step summary', integration: true do

    def setup_checkout
      create_region(
        name: 'Pennsylvania',
        abbreviation: 'PA',
        country: create_country(alpha_2_code: 'US')
      )

      create_shipping_method(
        name: 'Ground',
        tax_code: '001',
        rates: [{ price: 7.to_m }]
      )

      product = create_product(
        name: 'Integration Product',
        variants: [
          {
            sku: 'SKU1',
            regular: 6.to_m,
            tax_code: '001',
            sale_starts_at: Time.now - 1.day,
            sale: 5.to_m
          }
        ]
      )

      post store_front.cart_items_path, {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 2
        }

      post store_front.checkout_path, guest: true

      patch store_front.checkout_addresses_path,
        email: 'bcrouse@weblinc.com',
        billing_address: {
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '12 N. 3rd St.',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US',
          phone_number: '2159251800'
        },
        shipping_address: {
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          street_2: 'Apt 1',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US',
          phone_number: '2159251800'
        }
    end

    describe '#updated_shipping_step_summary' do
      it 'sets the avatax api flag to true then false' do
        setup_checkout

        expect(controller.current_order.call_avatax_api_flag).to be false

        # call_avatax_api_flag set to true within method then unset
        xhr :patch, '/checkout/shipping#update_shipping'

        expect(controller.current_order.call_avatax_api_flag).to be false
      end
    end
  end
end
