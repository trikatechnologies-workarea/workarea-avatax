module Workarea
  module Factories
    module AvataxFactories
      Factories.add self

      def create_checkout_order(overrides = {})
        attributes = overrides

        shipping_service = create_shipping_service(tax_code: "P0000000")
        sku = "SKU1"
        product = create_product(variants: [{ sku: sku, regular: 5.to_m, tax_code: "P0000000" }])

        Workarea::Order.new(attributes).tap do |order|
          shipping = Workarea::Shipping.create!(order_id: order.id)

          shipping.set_shipping_service(
            id: shipping_service.id,
            name: shipping_service.name,
            base_price: shipping_service.rates.first.price,
            tax_code: shipping_service.tax_code
          )

          order.items.build(
            product_id: product.id,
            sku: sku,
            quantity: 2,
            product_attributes: product.as_document
          )

          shipping.set_address(
            first_name:  "Eric",
            last_name:   "Pigeon",
            street:      "22 S 3rd St",
            city:        "Philadelphia",
            region:      "PA",
            postal_code: 19106,
            country:     "US"
          )

          Workarea::Pricing.perform(order)

          order.save!
        end
      end
    end
  end
end
