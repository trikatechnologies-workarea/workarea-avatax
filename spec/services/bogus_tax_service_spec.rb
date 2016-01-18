require 'spec_helper'

module Weblinc
  module Avatax
    describe BogusTaxService do
      subject(:gateway) do
        Weblinc::Avatax::BogusTaxService.new
      end

      describe 'method forwarding' do
        it 'should respond to public sailthru gateway messages' do
          expect(gateway.get).to eq true
          expect(gateway.post).to eq true
          expect(gateway.commit).to eq true
        end
      end
    end
  end
end
