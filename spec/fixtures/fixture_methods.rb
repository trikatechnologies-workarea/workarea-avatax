module Weblinc
  module Avatax
    module FixtureMethods
      def create_order_with_items(overrides={})
        attributes = {
          number: Faker::Number.number(5)
        }.merge(overrides)

        shipping_method = create_shipping_method
        sku = Faker::Lorem.characters(6).upcase
        product = create_product(variants: [{ sku: sku, regular: 5.to_m, tax_code: 'P0000000' }])

        Weblinc::Order.new(attributes).tap do |order|
          order.set_shipping_method(
            id: shipping_method.id,
            name: shipping_method.name,
            base_price: shipping_method.rates.first.price,
            tax_code: shipping_method.tax_code
          )
          order.items.build(product_id: product.id, sku: sku, quantity: 2)

          Weblinc::Pricing.perform(order)

          order.save!
        end
      end
    end
  end
end
