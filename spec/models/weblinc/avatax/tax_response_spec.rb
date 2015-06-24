require 'spec_helper'

module Weblinc
  module Avatax
    describe TaxResponse do |variable|
      before(:all) do
        # need to ensure some default settings
        Weblinc::Avatax::Setting.current.update_attributes(
          account_number: Faker::Number.number(10),
          license_key: Faker::Lorem.characters(10),
          company_code: 'MYCOMPANYCODE',
          doc_handling: :commit
        )
      end

      let(:user) { create_user }
      let!(:order) { create_checkout_order(email: user.email) }
      let!(:shipments) { Weblinc::Shipping::Shipment.where(number: order.number) }
      let!(:tax_request) { Weblinc::Avatax::TaxRequest.new(order, shipments, user: user) }
      let!(:api_response) { mock_successful_api_response(tax_request) }
      let!(:tax_response) do
        Weblinc::Avatax::TaxResponse.new(
          avatax_response: api_response,
          tax_request: tax_request,
          endpoint: 'TEST'
        )
      end

      describe '#order_item_lines' do
        it 'should return lines when passed an order item' do
          lines = tax_response.order_item_lines(order.items.first.id.to_s)
          expect(lines).not_to be_empty
        end

        it 'should have lines for each item' do
          order.items.each do |item|
            lines = tax_response.order_item_lines(item.id.to_s)
            expect(lines).not_to be_empty
          end
        end
      end

      describe '#shipment_lines' do
        it 'should return lines when passed a shipment' do
          lines = tax_response.shipment_lines(shipments.first.id.to_s)
          expect(lines).not_to be_empty
        end

        it 'should have lines for each shipment' do
          shipments.each do |shipment|
            lines = tax_response.shipment_lines(shipment.id.to_s)
            expect(lines).not_to be_empty
          end
        end
      end

    end
  end
end
