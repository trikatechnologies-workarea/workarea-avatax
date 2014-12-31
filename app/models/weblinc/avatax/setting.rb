module Weblinc
  module Avatax
    class Setting
      include Mongoid::Document
      include SiteSpecific

      field :account_number, type: String
      field :license_key,    type: String
      field :service_url,    type: String
      field :company_code,   type: String


      def self.find_or_create_by_id(id)
        where(id: id).first || new.tap do |setting|
          setting.id = id
          setting.save!
        end
      end

      def self.current
        find_or_create_by_id(Site.current.id)
      end
   
      def apply_settings
        settings = self  
        AvaTax.configure do 
          account_number settings.account_number
          license_key    settings.license_key
	  service_url    settings.service_url
        end
      end

      def settings_edit_hash
        setting.attributes.reject{|k,v| k.in?(ignore_fields)}
      end

      private

        def ignore_fields
          ["_id","deleted_at","site_id"]
        end

        def setting
          @setting ||= self.class.current
        end
    end
  end
end
