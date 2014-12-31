module Weblinc
  class Admin::AvataxTestConnectionsController < Admin::ApplicationController
    def show
       current_settings = Weblinc::Avatax::Setting.current
       current_settings.apply_settings
       @settings = current_settings.settings_edit_hash
    end

    def update

      taxSvc = AvaTax::TaxService.new

      begin  # catch exception if service URL is not valid
        pingResult = taxSvc.ping
        if pingResult["ResultCode"] == "Success"
          flash[:success] = 'AvaTax connecton successful.'
        else
          flash[:error] = pingResult["Messages"].collect { |message| message["Summary"] }
        end
      rescue Exception => e  
          flash[:error] = e.message
      end


      redirect_to avatax_test_connection_path
    end

    private
 
  end
end
