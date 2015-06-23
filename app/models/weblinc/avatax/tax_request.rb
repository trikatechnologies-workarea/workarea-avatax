module Weblinc
  module Avatax
    class TaxRequest
      attr_accessor :order, :user
      attr_writer :commit, :doc_type

      DEFAULT_DEST_CODE = "DEST"
      DEFAULT_ORIGIN_CODE = "ORIGIN"
      SHIPPING_LINE_PREFIX = "SHIPPING-"

      def initialize(order, shipments, options = {})
        @order = order
        @shipments = shipments
        @commit = options[:commit]
        @doc_type = options[:doc_type]
        @user = options[:user]
      end

      # PurchaseOrder type means that the document will not be saved
      # PurchaseInvoice type means that the document will be saved and
      # appear in the Avatax admin
      def doc_type
        if settings.doc_handling == :none || @doc_type.nil?
          "SalesOrder"
        else
          @doc_type
        end
      end

      def commit
        if settings.doc_handling == :none || @commit.nil?
          false
        else
          @commit
        end
      end

      # if we're not comitting don't bother with a real customer code since
      # the document is temporary anyway (via DocType). Must be < 50 chars
      def customer_code
        if doc_type == "SalesInvoice"
          order.email.truncate(50, omission: '')
        else
          "TEMPORARY"
        end
      end

      def doc_code
        "ORDER-#{order.number}"
      end

      def distribution_address
        dist_center = { AddressCode: DEFAULT_ORIGIN_CODE }
        dist_center.merge(Weblinc::Avatax.config.dist_center)
      end

      def shipping_address
        address = @shipments.first.address
        {
          AddressCode: DEFAULT_DEST_CODE,
          Line1: address.street,
          Line2: address.street_2,
          City: address.city,
          Region: address.region,
          Country: address.country,
          PostalCode: address.postal_code
        }
      end

      def item_lines
        @item_lines ||= @order.items.flat_map.with_index do |item, i|
          adjustments = item.price_adjustments.select do |a|
            !a.discount? && a.price == 'item'
          end
          tax_codes = adjustments.map { |a| a.data['tax_code'] }

          tax_codes.uniq.map do |code|
            Weblinc::Avatax::ItemLine.new(item: item, tax_code: code)
          end
        end
      end

      def shipping_lines
        @shipping_lines ||= @shipments.map do |shipment|
          Weblinc::Avatax::ShippingLine.new(shipment: shipment, tax_code: 'FR')
        end
      end

      def lines
        item_lines + shipping_lines
      end

      def exemption_no
        user.try(:exemption_no)
      end

      def usage_type
        user.try(:customer_usage_type)
      end

      def as_json
        apply_line_numbers! # line numbers are only relevant for one request cycle

        hash = {
          CustomerCode: customer_code,
          DocType: doc_type,
          Commit:  commit,
          DocDate: Time.now.strftime("%Y-%m-%d"),
          CompanyCode:  settings.company_code,
          Client:  "WEBLINC AVATAX CONNECTOR #{Weblinc::Avatax::VERSION}",
          DocCode:  doc_code,
          DetailLevel:  "Tax",
          Addresses:  [distribution_address, shipping_address],
          Lines:  lines.map(&:as_json)
        }

        if exemption_no.present?
          hash[:ExemptionNo] = exemption_no
        end

        if usage_type.present?
          hash[:CustomerUsageType] = usage_type
        end

        hash
      end

      # applies sequential line numbers to each line per Avatax Certification
      def apply_line_numbers!
        lines.each.with_index { |li, k| li.line_no = k + 1 }
      end

      private

      def settings
        @settings ||= Weblinc::Avatax::Setting.current
      end
    end
  end
end
