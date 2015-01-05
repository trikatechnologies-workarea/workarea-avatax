module Weblinc
  module Avatax
    class LineFactory
      def self.make_item_lines(item, line_prefix)
        taxable = make_taxable_item_lines(item, line_prefix)

        discount = make_discount_item_lines(item, line_prefix)

        taxable + discount
      end

      def self.make_taxable_item_lines(item, line_prefix)
        get_taxable_adjustments(item).map.with_index do |adjustment, index|
          line = Line.new(
            adjustment: adjustment,
            item: item,
            line_no: "#{line_prefix}-TAXABLE-#{index}"
          )
          line.to_request
        end
      end

      def self.make_discount_item_lines(item, line_prefix)
        discounts = item.price_adjustments.discounts
        taxable_adjustments = get_taxable_adjustments(item)

        # for each discount on an item we need to make a line for each of the
        # taxable ajustments, reflecting that adjustment's share of the discount.
        # because each taxable adjustment can have its own tax code.
        discounts.flat_map.with_index do |discount, disc_index|
          line_no_suffix = "DISCOUNT-#{disc_index}"
          taxable_total = taxable_adjustments.sum(&:amount)

          taxable_adjustments.map.with_index do |adjustment, tx_index|
            taxable_share = adjustment.amount / taxable_total
            line = Line.new(
              adjustment: discount,
              item: item,
              line_no: "#{line_prefix}-TAXABLE-#{tx_index}-#{line_no_suffix}",
              share: taxable_share
            )
            line.to_request
          end
        end
      end

      def self.get_taxable_adjustments(item)
        item.price_adjustments.reject do |adjustment|
          adjustment.discount? || adjustment.data['tax_code'].blank?
        end
      end

    end
  end
end
