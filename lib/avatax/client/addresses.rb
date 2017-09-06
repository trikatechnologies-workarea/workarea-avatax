module AvaTax
  class Client
    module Addresses 


      # Retrieve geolocation information for a specified address
      #
      # Resolve an address against Avalara's address-validation system. If the address can be resolved, this API
      # provides the latitude and longitude of the resolved location. The value 'resolutionQuality' can be used
      # to identify how closely this address can be located. If the address cannot be clearly located, use the
      # 'messages' structure to learn more about problems with this address.
      # This is the same API as the POST /api/v2/addresses/resolve endpoint.
      # Both verbs are supported to provide for flexible implementation.
      # @param line1 [String] Line 1
      # @param line2 [String] Line 2
      # @param line3 [String] Line 3
      # @param city [String] City
      # @param region [String] State / Province / Region
      # @param postalCode [String] Postal Code / Zip Code
      # @param country [String] Two character ISO 3166 Country Code (see /api/v2/definitions/countries for a full list)
      # @param textCase [String] selectable text case for address validation (See TextCase::* for a list of allowable values)
      # @param latitude [BigDecimal] Geospatial latitude measurement
      # @param longitude [BigDecimal] Geospatial longitude measurement
      # @return [Object]
      def resolve_address(options={})
        path = "/api/v2/addresses/resolve"
        get(path, options)
      end


      # Retrieve geolocation information for a specified address
      #
      # Resolve an address against Avalara's address-validation system. If the address can be resolved, this API
      # provides the latitude and longitude of the resolved location. The value 'resolutionQuality' can be used
      # to identify how closely this address can be located. If the address cannot be clearly located, use the
      # 'messages' structure to learn more about problems with this address.
      # This is the same API as the GET /api/v2/addresses/resolve endpoint.
      # Both verbs are supported to provide for flexible implementation.
      # @param model [Object] The address to resolve
      # @return [Object]
      def resolve_address_post(model)
        path = "/api/v2/addresses/resolve"
        post(path, model)
      end

    end
  end
end