module Weblinc
  module Avatax
    class Setting
      include Mongoid::Document
      include Mongoid::Enum
      include SiteSpecific

      field :account_number, type: String
      field :license_key,    type: String
      field :service_url,    type: String
      field :company_code,   type: String

      enum :doc_handling, [:commit, :post, :none], default: :commit

      def self.find_or_create_by_id(id)
        where(id: id).first || new.tap do |setting|
          setting.id = id
          setting.save!
        end
      end

      def self.current
        @@current ||= find_or_create_by_id(Site.current.id)
      end
    end
  end
end
