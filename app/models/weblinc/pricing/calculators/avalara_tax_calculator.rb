module Weblinc
  module Pricing
    module Calculators
      class AvalaraTaxCalculator
        include Calculator

        def taxable_items
          @taxable_items ||= order.items.select do |item|
            item.price_adjustments.sum > 0
          end
        end

        def shipping_total
          @shipping_total ||= order.shipping_method.price_adjustments.sum
        end

        def adjust
          return unless order.shipping_address.present?

#          taxable_items.each do |item|
#            assign_item_tax(item)
#          end
puts "MRA order.items.inspect",order.items.inspect
           avalara_with_fake_data
          

          assign_shipping_tax if order.shipping_method.present?
        end

        private

        def assign_item_tax(item)
          item_tax_total = 0.to_m

          discount_adjustments = item.price_adjustments.discounts
          taxable_adjustments = item.price_adjustments.reject do |adjustment|
            adjustment.discount? || adjustment.data['tax_code'].blank?
          end

          discount_total = discount_adjustments.sum(&:amount).to_m.abs
          taxable_total = taxable_adjustments.sum(&:amount).to_m

          taxable_adjustments.each do |adjustment|
            discount_share = adjustment.amount / taxable_total
            discount_amount = discount_total * discount_share
            taxable_amount = adjustment.amount - discount_amount

            rate = Tax.find_rate(
              adjustment.data['tax_code'],
              taxable_amount,
              order.shipping_address
            )
#MRA
#<Weblinc::Tax::Rate _id: 54886a954d6172a590af0000, percentage: 0.07, country: "US", region: "PA", postal_code: nil, charge_on_shipping: true, tier_min_cents: nil, tier_min_currency: nil, tier_max_cents: nil, tier_max_currency: nil, category_id: BSON::ObjectId('54886a954d6172a590ae0000')>
            avalara_tax_result = avalara_with_fake_data
puts "MRA avalara_tax_result: ",avalara_tax_result.inspect
	    rate.percentage = 1.00
            rate.charge_on_shipping = false

            item_tax_total += taxable_amount * rate.percentage
            item_tax_total = avalara_tax_result.total_tax.to_f
          end

          if item_tax_total > 0
            item.adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Tax',
              amount: item_tax_total
            )
          end
        end

        def assign_shipping_tax
          return unless shipping_total > 0

          tax_rate = Tax.find_rate(
            order.shipping_method.tax_code,
            shipping_total,
            order.shipping_address
          )

          return unless tax_rate.charge_on_shipping?

          amount = shipping_total * tax_rate.percentage

          if amount > 0
            order.shipping_method.adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Tax',
              amount: amount
            )
          end
        end

        def avalara_with_fake_data
 puts "MRA order.items.class",order.items.class
 
          lines = []
          order.items.each_with_index do |item, index| 
            line = {
              :LineNo => index,
              :ItemCode => item.sku,
              :Qty => item.quantity,
              :Amount => item.total_price_cents/100,
              :OriginCode => "01",
              :DestinationCode => "01",
              # Best Practice Request Parameters
              # :Description => "Red Size 7 Widget",
              :TaxCode => "P0000000"                   #TODO  get proper TaxCode
            }
            lines << line
           end
            
           getTaxRequest = {
             :CustomerCode => "REVELRYLABSDEV",
             :DocDate => "2014-01-01",
             :CompanyCode => "REVELRYLABSDEV",
             :Client => "AvaTaxSample",
             :DocCode => "INV001",
             :DetailLevel => "Tax",
             :Commit => false,
             :DocType => "SalesInvoice",
            
             :PurchaseOrderNo => "PO123456",
             :ReferenceCode => "ref123456",
             :PosLaneCode => "09",
             :CurrencyCode => "USD",
            
             # Address Data
             :Addresses =>
             [
               {
                 :AddressCode => "01",
                 :Line1 => "4820 Banks Street",
                 :City => "New Orleans",
                 :Region => "LA",
               }
             ],
            
             # Line Data
             :Lines => lines
           }
           #taxSvc = AvaTax::TaxService.new
           getTaxResult = AvaTax::TaxService.new.get(getTaxRequest)

            if getTaxResult["ResultCode"] != "Success"
              # TODO What to do if service is unavailable or we just be broken
              puts "MRA" + getTaxResult["ResultCode"]
              getTaxResult["Messages"].each { |message| puts "MRA :",message["Summary"] }
            else
              getTaxResult["TaxLines"].each do |taxLine|
                idx = taxLine["LineNo"].to_i
                tax = taxLine["Tax"].to_f
                if tax > 0
                  item = order.items[idx]
                  item.adjust_pricing(
                    price: 'tax',
                    calculator: self.class.name,
                    description: 'Tax',
                    amount: tax
                  )
                end
              end
            end
           getTaxResult 
        end
      end
    end
  end
end
