module Weblinc::Avatax::CheckoutControllerExtensions
  def setup_view_models
    current_order.call_avatax_api_flag= true
    super
    current_order.call_avatax_api_flag= false
  end

  def place_order
    current_order.call_avatax_api_flag= true
    super
    current_order.call_avatax_api_flag= false
  end
end


Weblinc::StoreFront::CheckoutsController.class_eval do
  prepend Weblinc::Avatax::CheckoutControllerExtensions
end
