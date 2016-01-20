module Weblinc
  class Admin::Avatax::TestConnectionsController < Admin::ApplicationController
    required_permissions :avatax_test_connections

    def show
      current_settings = Weblinc::Avatax::Setting.current
      @connection = Weblinc::Avatax::TaxService.ping
      @settings =
        {
          service_url:    current_settings[:service_url],
          account_number: current_settings[:account_number],
          license_key:    current_settings[:license_key],
          company_code:   current_settings[:company_code]
        }
    end
  end
end
