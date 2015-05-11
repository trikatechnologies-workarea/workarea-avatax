require 'spec_helper'

module Weblinc
  module Avatax
    describe TaxService do
      before(:all) do
        Weblinc::Avatax::Setting.current.update_attributes(
          account_number: Faker::Number.number(10),
          license_key: Faker::Lorem.characters(10),
          company_code: 'MYCOMPANYCODE',
          doc_handling: :commit
        )
      end

      let(:user) { create_user }
      let!(:order) { create_checkout_order(email: user.email) }

      describe '.new' do
        context 'shipments are not passed in' do
          let!(:service) { Weblinc::Avatax::TaxService.new(order) }

          it "should query for shipments" do
            expect(Weblinc::Shipping::Shipment).to receive(:where)
            Weblinc::Avatax::TaxService.new(order)
          end

          it "should have shipments" do
            expect(service.shipments).not_to be_empty
          end
        end

        context 'shipments are passed in' do
          it "should query for shipments if none are passed in" do
            shipments = [Weblinc::Shipping::Shipment.new]

            expect(Weblinc::Shipping::Shipment).not_to receive(:where)
            Weblinc::Avatax::TaxService.new(order, shipments)
          end
        end
      end
    end
  end
end
