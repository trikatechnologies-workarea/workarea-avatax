require 'spec_helper'

module Weblinc
  module Avatax
    describe TaxRequest do
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

      describe '#doc_code' do
        it 'should be present' do
          expect(tax_request.doc_type).to be_present
        end

        it 'should include the order number' do
          expect(tax_request.doc_code).to include(order.number)
        end
      end

      describe '#customer_code' do
        it 'should be present' do
          expect(tax_request.customer_code).to be_present
        end

        context '#doc_type is SalesInvoice' do
          let(:long_email) { 'thisisthelongestemailicouldcomeupwith@verylongemails.com' }
          let!(:order) { create_order(email: long_email) }

          let!(:tax_request) do
            Weblinc::Avatax::TaxRequest.new(order, shipments,
              user: user,
              doc_type: 'SalesInvoice'
            )
          end

          it 'should match the first 50 characters of the order email' do
            expect(tax_request.customer_code).to eq(long_email[0, 50])
          end
        end
      end

      describe '#item_lines' do
        it 'should be an array' do
          expect(tax_request.item_lines.class).to eq(Array)
        end

        it 'should not be empty' do
          expect(tax_request.item_lines).not_to be_empty
        end

        it 'should not have shipping lines' do
          line_numbers = tax_request.item_lines.map { |l| l.item_code }
          expect(line_numbers).not_to include('SHIPPING')
        end
      end

      describe '#shipping_lines' do
        it 'should be an Array' do
          expect(tax_request.shipping_lines.class).to eq(Array)
        end

        it 'should not be empty' do
          expect(tax_request.shipping_lines).not_to be_empty
        end

        it 'should include shipping lines' do
          line_numbers = tax_request.shipping_lines.map { |l| l.item_code }
          expect(line_numbers).to include('SHIPPING')
        end
      end

      describe '#lines' do
        it 'should be an array' do
          expect(tax_request.lines.class).to eq(Array)
        end

        it 'should not be empty' do
          expect(tax_request.lines).not_to be_empty
        end

        it 'should be a superset of #item_lines' do
          # easiest way to compare them as hashes for purposes of this test
          # is to use the as_json representation from active support
          expect(tax_request.lines).to include(*tax_request.item_lines)
        end

        it 'should include #shipping_lines' do
          expect(tax_request.lines).to include(*tax_request.shipping_lines)
        end
      end

      describe '#shipping_address' do
        it 'should be present' do
          expect(tax_request.shipping_address).to be_present
        end
      end

      describe '#distribution_address' do
        it 'should be present' do
          expect(tax_request.distribution_address).to be_present
        end
      end

      describe '#commit' do
        it 'should be false' do
          expect(tax_request.commit).to be_falsey
        end

        context 'custom value passed in' do
          let!(:tax_request) do
            Weblinc::Avatax::TaxRequest.new(order, shipments,
              commit: true
            )
          end

          it 'reflects the passed in value' do
            expect(tax_request.commit).to be_truthy
          end
        end
      end

      describe '#doc_type' do
        it 'should be SalesOrder' do
          expect(tax_request.doc_type).to eq("SalesOrder")
        end

        context 'custom value passed in' do
          let!(:tax_request) do
            Weblinc::Avatax::TaxRequest.new(order, shipments,
              doc_type: 'SalesInvoice'
            )
          end

          it 'should return the value passed in' do
            expect(tax_request.doc_type).to eq('SalesInvoice')
          end
        end
      end

      describe '#exemption_no' do
        it 'should not be present' do
          expect(tax_request.exemption_no).not_to be_present
        end

        context 'order user has an exemption number' do
          let(:user) { create_user(exemption_no: '12345') }

          it 'should be present' do
            expect(tax_request.exemption_no).to be_present
          end
        end
      end

      describe '#usage_type' do
        it 'should be blank' do
          expect(tax_request.usage_type).to be_blank
        end

        context 'order user has a usage_type' do
          let(:user) { create_user(customer_usage_type: 'A') }

          it 'should be present' do
            expect(tax_request.usage_type).to be_present
          end
        end
      end

      context 'doc_handling is :none in the current settings' do
        before(:all) do
          @settings = Weblinc::Avatax::Setting.current
          @old_doc_handling = @settings.doc_handling
          @settings.update_attributes(doc_handling: :none)
        end

        describe '#doc_type' do
          it 'should be SalesOrder' do
            expect(tax_request.doc_type).to eq('SalesOrder')
          end
        end

        describe '#commit' do
          it 'should be false' do
            expect(tax_request.commit).to be_falsey
          end
        end

        after(:all) do
          @settings.update_attributes(doc_handling: @old_doc_handling)
        end
      end
    end
  end
end
