Weblinc::Avatax::Engine.routes.draw do
end

Weblinc::Admin::Engine.routes.draw do
  resource  :avatax_settings, only: [:show, :update]
  resource  :avatax_test_connection, only: [:show, :update]
end
