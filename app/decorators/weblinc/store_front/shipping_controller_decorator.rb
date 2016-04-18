module Weblinc
  decorate(StoreFront::Checkout::Shipping, with: 'avatax') do
    private

    def updated_shipping_step_summary
      current_order.call_avatax_api_flag = true
      super
    end
  end
end
