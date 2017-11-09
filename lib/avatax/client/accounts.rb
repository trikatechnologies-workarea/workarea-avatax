module AvaTax
  class Client
    module Accounts 


      # Reset this account's license key
      #
      # Resets the existing license key for this account to a new key.
      #
      # To reset your account, you must specify the ID of the account you wish to reset and confirm the action.
      #
      # This API is only available to account administrators for the account in question, and may only be called after
      # an account has been activated by reading and accepting Avalara's terms and conditions. To activate your account
      # please log onto the AvaTax website or call the `ActivateAccount` API.
      #
      # Resetting a license key cannot be undone. Any previous license keys will immediately cease to work when a new key is created.
      #
      # When you call this API, all account administrators for this account will receive an email with the newly updated license key.
      # The email will specify which user reset the license key and it will contain the new key to use to update your connectors.
      # @param id [Integer] The ID of the account you wish to update.
      # @param model [Object] A request confirming that you wish to reset the license key of this account.
      # @return [Object]
      def account_reset_license_key(id, model)
        path = "/api/v2/accounts/#{id}/resetlicensekey"
        post(path, model)
      end


      # Activate an account by accepting terms and conditions
      #
      # Activate the account specified by the unique accountId number.
      #
      # This activation request can only be called by account administrators. You must indicate
      # that you have read and accepted Avalara's terms and conditions to call this API.
      #
      # Once you have activated your account, use the `AccountResetLicenseKey` API to generate
      # a license key for your account.
      #
      # If you have not read or accepted the terms and conditions, this API call will return the
      # unchanged account model.
      # @param id [Integer] The ID of the account to activate
      # @param include [String] Elements to include when fetching the account
      # @param model [Object] The activation request
      # @return [Object]
      def activate_account(id, model, options={})
        path = "/api/v2/accounts/#{id}/activate"
        post(path, model, options)
      end


      # Retrieve a single account
      #
      # Get the account object identified by this URL.
      # You may use the '$include' parameter to fetch additional nested data:
      #
      # * Subscriptions
      # * Users
      # @param id [Integer] The ID of the account to retrieve
      # @param include [String] A comma separated list of special fetch options
      # @return [Object]
      def get_account(id, options={})
        path = "/api/v2/accounts/#{id}"
        get(path, options)
      end


      # Get configuration settings for this account
      #
      # Retrieve a list of all configuration settings tied to this account.
      #
      # Configuration settings provide you with the ability to control features of your account and of your
      # tax software. The category names `TaxServiceConfig` and `AddressServiceConfig` are reserved for
      # Avalara internal software configuration values; to store your own account-level settings, please
      # create a new category name that begins with `X-`, for example, `X-MyCustomCategory`.
      #
      # Account settings are permanent settings that cannot be deleted. You can set the value of an
      # account setting to null if desired.
      #
      # Avalara-based account settings for `TaxServiceConfig` and `AddressServiceConfig` affect your account's
      # tax calculation and address resolution, and should only be changed with care.
      # @param id [Integer] 
      # @return [AccountConfigurationModel[]]
      def get_account_configuration(id)
        path = "/api/v2/accounts/#{id}/configuration"
        get(path)
      end


      # Change configuration settings for this account
      #
      # Update configuration settings tied to this account.
      #
      # Configuration settings provide you with the ability to control features of your account and of your
      # tax software. The category names `TaxServiceConfig` and `AddressServiceConfig` are reserved for
      # Avalara internal software configuration values; to store your own account-level settings, please
      # create a new category name that begins with `X-`, for example, `X-MyCustomCategory`.
      #
      # Account settings are permanent settings that cannot be deleted. You can set the value of an
      # account setting to null if desired.
      #
      # Avalara-based account settings for `TaxServiceConfig` and `AddressServiceConfig` affect your account's
      # tax calculation and address resolution, and should only be changed with care.
      # @param id [Integer] 
      # @param model [AccountConfigurationModel[]] 
      # @return [AccountConfigurationModel[]]
      def set_account_configuration(id, model)
        path = "/api/v2/accounts/#{id}/configuration"
        post(path, model)
      end

    end
  end
end