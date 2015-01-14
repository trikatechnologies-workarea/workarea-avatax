module Weblinc
  module Avatax
    class UsageType
      include Mongoid::Document

      field :code, type: String
      field :name, type: String
    end
  end
end
