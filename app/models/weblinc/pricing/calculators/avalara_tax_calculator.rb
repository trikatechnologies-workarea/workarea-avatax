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
          getAvatax
        end

        private

        def getAvatax
          request = {
            :CustomerCode => order.email,             #TODO ?email > 50Chars?
            :DocDate => Time.now.strftime("%Y-%m-%d"),
            :CompanyCode => Weblinc::Avatax.config.company_code,
            :Client => "WEBLINC",
            :DocCode => "INV #{order.number}",
            :DetailLevel => "Tax",
            :Commit => false,
            :DocType => "SalesInvoice",
            :Addresses => [ distribution_address, shipping_address ],
            :Lines => item_lines.push(shipping_line)
          }

          getTaxResult = AvaTax::TaxService.new.get(request)

          if getTaxResult["ResultCode"] == "Success"
            lines_shipping = getTaxResult['TaxLines']
              .select { |l| l['LineNo'] == 'SHIPPING' }
            lines_items = getTaxResult['TaxLines'] - lines_shipping

            lines_items.each do |line|
              line_index = line['LineNo'].to_i
              item = order.items[line_index]
              item.adjust_pricing(
                price: 'tax',
                calculator: self.class.name,
                description: 'Sales Tax',
                amount: line['Tax'].to_m
              )
            end

            lines_shipping.each do |line|
              order.shipping_method.adjust_pricing(
                price: 'tax',
                calculator: self.class.name,
                description: 'Sales Tax',
                amount: line['Tax'].to_m
              )
            end
          else
            Rails.logger.error "AvaTax getTax call Failed: " + result["ResultCode"]
            result["Messages"].each { |message| Rails.logger.error message["Summary"] }
          end

          getTaxResult
        end

        def distribution_address
          dist_center = { AddressCode: Weblinc::Avatax::DEFAULT_ORIGIN_CODE }
          dist_center.merge(Weblinc::Avatax.config.dist_center)
        end

        def shipping_address
          {
            AddressCode: Weblinc::Avatax::DEFAULT_DEST_CODE,
            Line1: order.shipping_address.street,
            Line2: order.shipping_address.street_2,
            City: order.shipping_address.city,
            Region: order.shipping_address.region,
            Country: order.shipping_address.country,
            PostalCode: order.shipping_address.postal_code
          }
        end

        def item_lines
          lines = order.items.flat_map.with_index do |item, index|
            Weblinc::Avatax::LineFactory.make_item_lines(item, index)
          end

          lines.as_json # get a hash representation
        end

        def shipping_line
          shipping_total = order.shipping_method.price_adjustments.sum

          {
            LineNo: "SHIPPING",
            ItemCode: "SHIPPING",
            Description: order.shipping_method.name,
            Qty: 1,
            Amount: shipping_total.to_s,
            OriginCode: Weblinc::Avatax::DEFAULT_ORIGIN_CODE,
            DestinationCode: Weblinc::Avatax::DEFAULT_DEST_CODE
          }
        end
      end
    end
  end
end
