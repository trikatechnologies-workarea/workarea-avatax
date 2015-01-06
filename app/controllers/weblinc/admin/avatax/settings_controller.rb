module Weblinc

  class Admin::Avatax::SettingsController < Admin::ApplicationController
    def show
       current_settings = Weblinc::Avatax::Setting.current
       @settings_drop = settings_drop_hash(current_settings)
       @settings_text = settings_text_hash(current_settings)
    end

    def update
      Weblinc::Avatax::Setting.current.update_attributes(setting_params)
      Weblinc::Avatax::Setting.current.apply_settings

      flash[:success] = 'AvaTax settings have been saved.'
      redirect_to avatax_settings_path
    end

     private
 
     def settings_text_hash(setting)
       { 
         account_number: setting[:account_number],
         license_key:    setting[:license_key],
         company_code:   setting[:company_code]
       }
     end

     def settings_drop_hash(setting)
       {
         service_url:  {
           selected:  setting[:service_url],
           container: Weblinc::Avatax.config.valid_service_urls
         }
       }
     end

     def setting_params
      params.require(:settings).permit(:account_number,:license_key,:service_url,:company_code)
     end
  end
end
