Weblinc.configure do |config|
  config.sites = [
    {
      id: 1,
      name: 'WebLinc Store Front',
      domain: 'www.example.com',
      api_token: '4f621e1970321568a5000005',
      email: {
        accounts: 'accounts@weblinc.com',
        orders: 'orders@weblinc.com',
        customer_service: 'customerservice@weblinc.com'
      }
    }
  ]

  config.asset_store = :file_system, {
    root_path: '/tmp/weblinc_store_front',
    server_root: '/tmp/weblinc_store_front'
  }
end

Weblinc::Avatax.configure do |config|
  config.dist_center = {
    Line1: '4820 Banks St',
    City: 'New Orleans',
    Region: 'LA',
   PostalCode: '70115'
 }
end
