module Weblinc
  decorate(StoreFront::CartViewModel, with: 'avatax') do # Specify the plugin name when decorating
    class_methods do
      def show_taxes?
        false  # forces display of "Calculated at Checkout"
      end
    end
  end
end
