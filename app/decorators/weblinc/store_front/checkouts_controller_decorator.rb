module Weblinc
  decorate(StoreFront::CheckoutsController, with: 'avatax') do # Specify the plugin name when decorating
    class_methods do
      def setup_view_models
        current_order.call_avatax_api_flag = true
        super
        current_order.call_avatax_api_flag = false
      end

      def place_order
        current_order.call_avatax_api_flag = true
        super
        current_order.call_avatax_api_flag = false
      end
    end
  end
end
