module Weblinc::Avatax::CheckoutControllerExtensions
  def setup_view_models
    #current_order.call_avatax_api_flag = !current_order.call_avatax_api_flag # cuts down on double call during place order
    current_order.call_avatax_api_flag= true
    super
    current_order.call_avatax_api_flag= false
    #current_order.call_avatax_api_flag = !current_order.call_avatax_api_flag # cuts down on double call during place order
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
