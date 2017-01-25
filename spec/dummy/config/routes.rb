Rails.application.routes.draw do
  mount Weblinc::StoreFront::Engine => '/', as: 'store_front'
  mount Weblinc::Avatax::Engine => "/avatax"
end
