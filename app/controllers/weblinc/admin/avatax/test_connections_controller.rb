module Weblinc
  class Admin::Avatax::TestConnectionsController < Admin::ApplicationController
    def show
      current_settings = Weblinc::Avatax::Setting.current
      ping
      @settings =
        {
          service_url:    current_settings[:service_url],
          account_number: current_settings[:account_number],
          license_key:    current_settings[:license_key],
          company_code:   current_settings[:company_code]
        }
    end

    private

    def ping
      tax_svc = Weblinc::Avatax::TaxService.new
      begin  # catch exception if service URL is not valid
        pingResult = tax_svc.ping
        if pingResult["ResultCode"] == "Success"
          @connection = {status: 'Service Available', errors: []}
        else
          @connection = {status: 'Errors'}
          @connection[:errors] = pingResult["Messages"].collect { |message| message["Summary"] }
          flash[:error] = 'Failure'
        end
      rescue Exception => e  
        @connection = {status: "Exception"}
        @connection[:errors] = [e.message]
        flash[:error] = 'Exception'
      end
    end
 
  end
end
