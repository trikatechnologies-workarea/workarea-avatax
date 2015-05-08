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
        avatax_response['TaxLines'].reject do |tax_line|
          tax_line['LineNo'] =~ /#{Weblinc::Avatax::TaxRequest::SHIPPING_LINE_PREFIX}/
        end
      end

      def shipping_lines
        return [] unless success?
        avatax_response['TaxLines'].select do |tax_line|
          tax_line['LineNo'] =~ /#{Weblinc::Avatax::TaxRequest::SHIPPING_LINE_PREFIX}/
        end
      end

      def item_adjustments
        item_lines.map do |line|
          {
            sku: line['LineNo'].split('-').first,
            amount: line['Tax'].to_m
          }
        end
      end

      def shipping_adjustments
        shipping_lines.map do |line|
          shipment_id = line['LineNo'].gsub(Weblinc::Avatax::TaxRequest::SHIPPING_LINE_PREFIX, '')
          { shipment_id: shipment_id, amount: line['Tax'].to_m }
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
