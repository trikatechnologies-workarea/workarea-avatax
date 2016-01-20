module Weblinc
  decorate(User, with: 'avatax') do # Specify the plugin name when decorating
    decorated do
      field :exemption_no, type: String
      field :customer_usage_type, type: String
      field :avatax_settings_access, type: Boolean, default: false
      field :avatax_test_connections_access, type: Boolean, default: false
    end
  end
end
