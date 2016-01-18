module Weblinc
  module Avatax
    class BogusTaxService
      def method_missing(method, *args)
        return true if supported_methods.include? method
        super
      end

      def supported_methods
        Weblinc::Avatax::TaxService.public_instance_methods
      end
    end
  end
end
