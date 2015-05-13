module Weblinc
  module Avatax
    class Setting
      include Mongoid::Document
      include Mongoid::Enum

      field :account_number, type: String
      field :license_key,    type: String
      field :service_url,    type: String
      field :company_code,   type: String

      enum :doc_handling, [:commit, :post, :none], default: :commit

      def self.find_or_create
        first || new.tap do |setting|
          setting.save!
        end
      end

      def self.current
        @@current ||= find_or_create
      end
    end
  end
end
