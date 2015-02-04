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
      let!(:order) { create_order_with_items(email: user.email) }
      let!(:tax_request) { Weblinc::Avatax::TaxRequest.new(order: order, user: user) }

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
            Weblinc::Avatax::TaxRequest.new(
              order: order,
              user: user,
              doc_type: 'SalesInvoice'
            )
          end

          it 'should match the first 50 characters of the order email' do
            expect(tax_request.customer_code).to eq(long_email[0, 50])
          end
        end
      end

      describe '#doc_code' do
        it 'should be present' do
          expect(tax_request.doc_code).to be_present
        end

      end

      describe '#item_lines' do
        it 'should be an array' do
          expect(tax_request.item_lines.class).to eq(Array)
        end

        it 'should not be empty' do
          expect(tax_request.item_lines).not_to be_empty
        end
      end

      describe '#shipping_line' do
        it 'should be a hash' do
          expect(tax_request.shipping_line.class).to eq(Hash)
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

        it 'should include #shipping_line' do
          expect(tax_request.lines).to include(tax_request.shipping_line)
        end
      end

      context 'doc_handling is :none in the current settings' do
        before(:all) do
          @settings = Weblinc::Avatax::Setting.current
          @old_doc_handling = @settings.doc_handling
          @settings.update_attributes(doc_handling: :none)
        end

        describe '#doc_type' do
          it 'should be false' do
            expect(tax_request.doc_type).to eq('SalesOrder')
          end
        end

        describe '#commit' do
          it 'should be false' do
            expect(tax_request.commit).to be_false
          end
        end

        after(:all) do
          @settings.update_attributes(doc_handling: @old_doc_handling)
        end
      end
    end
  end
end
