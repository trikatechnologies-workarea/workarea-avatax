module Weblinc
  decorate(Order, with: 'avatax') do
    decorated do
      field :call_avatax_api_flag, type: Boolean, default: false
    end
  end
end
