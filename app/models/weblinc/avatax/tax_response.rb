module Weblinc
  module Avatax
    class TaxResponse
      attr_accessor :avatax_response, :tax_request

      def initialize(options={})
        @avatax_response = options[:avatax_response] || {}
        @tax_request = options[:tax_request]
        @endpoint = options[:endpoint]
        log_errors if errors.present?
      end

      def status
        success? ? :success : :failure
      end

      def success?
        avatax_response['ResultCode'] == "Success"
      end

      def order_item_lines(order_item_id)
        return [] unless success?
        line_nums = tax_request
          .item_lines
          .select { |li| li.order_item_id == order_item_id }
          .map(&:line_no)

        avatax_response['TaxLines'].select do |tax_line|
          line_nums.include?(tax_line['LineNo'].to_i)
        end
      end

      def shipment_lines(shipment_id)
        return [] unless success?
        line_nums = tax_request
          .shipping_lines
          .select { |li| li.shipment_id == shipment_id }
          .map(&:line_no)

        avatax_response['TaxLines'].select do |tax_line|
          line_nums.include?(tax_line['LineNo'].to_i)
        end
      end

      def errors
        return [] if success?
        avatax_response['Messages'].map { |msg| msg['Summary'] }
      end

      private

      def log_errors
        Rails.logger.error "Avatax #{@endpoint} call failed"
        errors.each do |msg|
          Rails.logger.error "Avatax #{@endpoint}: #{msg}"
        end
      end
    end
  end
end
