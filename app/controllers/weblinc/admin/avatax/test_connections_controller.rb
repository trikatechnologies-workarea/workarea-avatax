module Weblinc
  class Admin::Avatax::TestConnectionsController < Admin::ApplicationController
    def show
      current_settings = Weblinc::Avatax::Setting.current
      current_settings.apply_settings
      ping
      @settings = current_settings.settings_edit_hash
    end

    #def update
    #  redirect_to avatax_test_connection_path
    #end

    private
    def ping
      taxSvc = AvaTax::TaxService.new
      begin  # catch exception if service URL is not valid
        pingResult = taxSvc.ping
        if pingResult["ResultCode"] == "Success"
          @connection = {status: 'Service Available', errors: []}
        else
          @connection = {status: 'Errors'}
          @connection[:errors] = pingResult["Messages"].collect { |message| message["Summary"] }
          flash[:error] = 'Failure'
        end
      rescue Exception => e  
        throw :mra
        @connection = {status: "Exception"}
        @connection[:errors] = [e.message]
        flash[:error] = 'Exception'
      end
    end
 
  end
end
