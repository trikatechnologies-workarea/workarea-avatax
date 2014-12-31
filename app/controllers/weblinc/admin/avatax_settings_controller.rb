module Weblinc
  class Admin::AvataxSettingsController < Admin::ApplicationController
    def show
       @settings = Weblinc::Avatax::Setting.current.settings_edit_hash
    end

    def update
      Weblinc::Avatax::Setting.current.update_attributes(setting_params)
      Weblinc::Avatax::Setting.current.apply_settings

      flash[:success] = 'AvaTax settings have been saved.'
      redirect_to avatax_settings_path
    end

     private
 
     def fields
       Weblinc::Avatax::Setting.current.settings_edit_hash.keys
     end

     def setting_params
      params.require(:settings).permit(fields)
     end
  end
end
