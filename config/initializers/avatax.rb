AvaTax.configure do
  account_number  = ENV['AVATAX_ACCOUNT_NUMBER'] || abort("AvaTax configuration is missing Account number.")
  license_key     = ENV['AVATAX_LICENSE_KEY']    || abort("AvaTax configuration is missing license key.")
  service_url     = ENV['AVATAX_SERVICE_URL']    || abort("AvaTax configuration is missing service_url.")
end
