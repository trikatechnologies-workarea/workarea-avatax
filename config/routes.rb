Weblinc::Avatax::Engine.routes.draw do
end

Weblinc::Admin::Engine.routes.draw do
  namespace :avatax do
    resource  :settings, only: [:show, :update]
    resource  :test_connection, only: [:show, :update]
  end
end
