module Weblinc
  class Admin::AvataxSettingsController < Admin::ApplicationController
    def show
       @settings = settings_hash
    end

    def update
      Weblinc::Avatax::Setting.current.update_attributes(setting_params)

      flash[:success] = 'AvaTax settings have been saved.'
      redirect_to avatax_settings_path
    end

     private
 
     def ignore_fields
       ["_id","deleted_at","site_id"]
     end

     def setting
       @setting ||= Weblinc::Avatax::Setting.current
     end 

     def fields
       settings_hash.keys
     end

     def settings_hash
       setting.attributes.reject{|k,v| k.in?(ignore_fields)}
     end

     def setting_params
      params.require(:settings).permit(fields)
     end
  end
end
