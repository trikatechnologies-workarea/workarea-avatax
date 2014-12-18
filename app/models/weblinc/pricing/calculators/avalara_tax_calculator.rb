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

           avalara_with_fake_data

        end

        private

        def avalara_tax_code(item)
          weblinc_tax_code =item.price_adjustments.inject("") do |tax_code, adjustment|
            tax_code + String(adjustment.data['tax_code'])
          end
          case weblinc_tax_code
          when ""
            tax_code = 'NT'
          when "001"
            tax_code = 'P0000000'
          else
            tax_code = weblinc_tax_code    #TODO
           end

           tax_code
        end

        def avalara_line_from_shipping_adjustment(adjustment,index)
          line = {
            :LineNo => "FR_"+index.to_s,
            :ItemCode => 'shipping',
            :Qty => adjustment.quantity,
            :Amount => adjustment.amount_cents/100,
            :OriginCode => "01",
            :DestinationCode => "02",
            :Description => adjustment.description,
            :TaxCode => 'FR'   #TODO what if data_code not "001"
          }
        end

        def avalara_lines_from_item(item,index)
          lines = []
          discount_adjustments = item.price_adjustments.discounts
          item.price_adjustments.each do |adjustment|
          end

          taxable_adjustments = item.price_adjustments.reject do |adjustment|
            adjustment.discount? || adjustment.data['tax_code'].blank?
          end

          discount_total = discount_adjustments.sum(&:amount).to_m.abs
          taxable_total = taxable_adjustments.sum(&:amount).to_m

          taxable_adjustments.each_with_index do |adjustment,adjustment_index|
            discount_share = adjustment.amount / taxable_total
            discount_amount = discount_total * discount_share
            taxable_amount = adjustment.amount - discount_amount
            tax_code = avalara_tax_code(item)
            line = {
              :LineNo => "#{index}-#{adjustment_index}",
              :ItemCode => item.sku,
              :Qty => item.quantity,
              :Amount => item.total_price_cents/100,
              :OriginCode => "01",
              :DestinationCode => "02",
              # Best Practice Request Parameters
              # :Description => "Red Size 7 Widget",
              :TaxCode => tax_code
            }
            lines << line
            discount_adjustments.each_with_index do |discount_adjustment,da_index| 
              discount_adjustment_amount = (discount_adjustment.amount_cents/100)*discount_share
              discount_line = {
                :LineNo => "#{index}-#{adjustment_index}-#{da_index.to_s}",
                :ItemCode => item.sku,  
                :Qty => discount_adjustment.quantity,
                :Amount => discount_adjustment_amount,
                :OriginCode => "01",
                :DestinationCode => "02",
                :Description =>  discount_adjustment.description,
                :TaxCode => tax_code
              }
              lines << discount_line
            end
          end
          lines
        end

        def avalara_assign_shipping_tax(taxLine)
          tax = taxLine["Tax"].to_f
          if tax > 0
            order.shipping_method.adjust_pricing(
              price: 'tax',
              calculator: self.class.name,
              description: 'Tax',
              amount: tax
            )
          end
        end

        def avalara_adjust_item_tax(tax,idx)
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

        def avalara_assign_item_tax(taxLine)
          idx = taxLine["LineNo"].to_i
          @itemTax[idx]=0 if @itemTax[idx].nil?
          tax = taxLine["Tax"].to_f
          @itemTax[idx] += tax
        end

        def avalara_assign_tax(taxLine)
          if (taxLine["LineNo"].index('FR_') == 0)
            avalara_assign_shipping_tax(taxLine)
          else
            avalara_assign_item_tax(taxLine)
          end
        end

        def mock_distribution_center_address
          {                                 # TODO: Hard coded Distribution Center
            :AddressCode => "01",
            :Line1 => "4820 Banks Street",
            :City => "New Orleans",
            :Region => "LA",
          }
        end

	def avalara_order_shipping_address
          {
            :AddressCode => "02",
            :Line1 => order.shipping_address.street,
            :Line2 => order.shipping_address.street_2,
            :City => order.shipping_address.city,
            :Region => order.shipping_address.region,
            :Country => order.shipping_address.country,
            :PostalCode => order.shipping_address.postal_code
          }
        end

	def avalara_with_fake_data
          lines = []
          order.items.each_with_index do |item, index|
            lines += avalara_lines_from_item(item, index)
          end
          order.shipping_method.price_adjustments.each_with_index do |adjustment, index|
            lines << avalara_line_from_shipping_adjustment(adjustment,index)
          end

          getTaxRequest = {
            :CustomerCode => order.email,             #TODO ?email > 50Chars?
            :DocDate => Time.now.strftime("%Y-%m-%d"),
            :CompanyCode => "REVELRYLABSDEV",         #TODO
            :Client => "AvaTaxSample",                #TODO
            :DocCode => "INV"+order.number,
            :DetailLevel => "Tax",
            :Commit => false,
            :DocType => "SalesInvoice",

            :Addresses => [ mock_distribution_center_address, avalara_order_shipping_address ],
            :Lines => lines
          }
          getTaxResult = AvaTax::TaxService.new.get(getTaxRequest)

          if getTaxResult["ResultCode"] != "Success"
            # TODO What to do if service is unavailable or we just be broken
            puts "MRA" + getTaxResult["ResultCode"]
            getTaxResult["Messages"].each { |message| puts "MRA :",message["Summary"] }
          else
            @itemTax=[]
            getTaxResult["TaxLines"].each do |taxLine|
              avalara_assign_tax(taxLine)
            end
            @itemTax.each_with_index do |tax,index|
              avalara_adjust_item_tax(tax,index)
            end
          end

          getTaxResult
        end

      end
    end
  end
end
