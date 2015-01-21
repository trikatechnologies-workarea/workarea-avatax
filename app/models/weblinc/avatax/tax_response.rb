module Weblinc
  module Avatax
    class TaxResponse
      attr_accessor :avatax_response

      def initialize(options={})
        @avatax_response = options[:avatax_response] || {}
        @endpoint = options[:endpoint]
        log_errors if errors.present?
      end

      def status
        success? ? :success : :failure
      end

      def success?
        avatax_response['ResultCode'] == "Success"
      end

      def item_lines
        return [] unless success?
        avatax_response['TaxLines'].reject { |l| l['LineNo'] == 'SHIPPING' }
      end

      def shipping_lines
        return [] unless success?
        avatax_response['TaxLines'].select { |l| l['LineNo'] == 'SHIPPING' }
      end

      def item_adjustments
        item_lines.map do |line|
          {
            sku: line['LineNo'].split('-').last,
            amount: line['Tax'].to_m 
          }
        end
      end

      def shipping_adjustments
        shipping_lines.map do |line|
          { sku: line['LineNo'], amount: line['Tax'].to_m }
        end
      end

      def errors
        return [] if success?
        avatax_response['Messages']
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
