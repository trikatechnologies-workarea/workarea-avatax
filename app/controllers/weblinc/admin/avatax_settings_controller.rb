module Weblinc
  class Admin::AvataxSettingsController < Admin::ApplicationController
    def show
#      @boosts   = Search::Index.current.boosts
       @boosts   = { 
        "Account Number" => "bar", 
        "License Key"    => "garble", 
        "Service URL"    => "http://www.jahoo.com", 
        "Company Code"   => "REVELRYLABDEV", 
       }
    end

    def update
#      Search::Index.current.update_settings(
#        rewrites: rewrites_to_save,
#        synonyms: params[:synonyms],
#        boosts: params[:boosts]
#      )
#
#      flash[:success] = 'Search settings have been saved.'
#      redirect_to search_settings_path
    end

    private

    def new_rewrites
    end

    def new_and_original_rewrites
    end

    def rewrites_to_save
    end
  end
end
