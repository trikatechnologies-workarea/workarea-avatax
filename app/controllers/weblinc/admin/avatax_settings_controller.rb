module Weblinc
  class Admin::AvataxSettingsController < Admin::ApplicationController
    def show
       @settings = hash_from_fields
    end

    def update
      Weblinc::Avatax::Setting.current.update_attributes(setting_params)

      flash[:success] = 'AvaTax settings have been saved.'
      redirect_to avatax_settings_path
    end

     private
 
     def fields
       [ :account_number, :license_key, :service_url, :company_code ]
     end

     def hash_from_fields
       settings = Weblinc::Avatax::Setting.current
       fields.inject({}) do |result, key|
         result[key] = settings[key]
         result
       end
     end

     def setting_params
      params.require(:settings).permit(fields)
     end
  end
end
