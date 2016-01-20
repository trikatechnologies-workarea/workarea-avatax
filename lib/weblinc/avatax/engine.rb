module Weblinc
  module Avatax
    include ActiveSupport::Configurable

    class Engine < ::Rails::Engine
      include Weblinc::Plugin

      isolate_namespace Weblinc::Avatax

      Weblinc::Avatax.configure do |config|
        config.valid_service_urls = [
          "https://development.avalara.net",   # development
          "https://avatax.avalara.net"         # production
        ]
      end

      initializer 'weblinc.avatax.templates' do
        Plugin.append_partials(
          'admin.store_menu',
          'weblinc/admin/menus/avatax_settings'
        )

        Plugin.append_partials(
          'admin.user_permissions',
          'weblinc/admin/users/avatax_settings'
        )
        Plugin.append_partials(
          'admin.user_properties',
          'weblinc/admin/users/user_properties_fields'
        )
      end

      initializer 'weblinc.avatax.listeners' do
        Weblinc::Publisher.add_listener(Weblinc::Avatax::InvoiceListener)
      end
    end
  end
end
