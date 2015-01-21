Weblinc::StoreFront::CartViewModel.class_eval do
  def show_taxes?
    false  # forces display of "Calculated at Checkout"
  end
end
