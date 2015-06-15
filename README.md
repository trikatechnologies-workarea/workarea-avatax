# Avatax

Avatax by Avalara provides a centralized service for tracking sales tax bills.
This plugin integrates that service into the Weblinc platform. Instead of using
the Weblinc platform's included sales tax caclulation system, it uses Avatax to
calculate sales tax. After an order is placed, that order's sales tax bill is
transmitted to Avatax. Users may choose to commit (save them so that they are
reflected in tax liability) posted documents either via Weblinc platform, or
via their own order management system.

## Features
#### Out of the Box
   * Tax rate determination using Geocoding
   * US Postal Service approved Address Validation
   * Full reporting feature with summarized and detailed reports
   * Constant real time updates with the latest rules and regulations for accuracy

#### Extendability
   * Global calculations
   * Consumer Use
   * State by State sales tax
   * Automated Filing and Remittance
   * Exemption Certificate Management

## Requirements
  * Access to your Weblinc administration
  * Avalara Avatax account(These values can be found in your Avalara administration console upon Registration)
    * Account Number
    * License Key
    * API URL
    * Shipping Item Code or Tax Code

## Installation and Configuration

#### 1) Add the Application gem to your gemfile in host application.
```ruby
  gem 'weblinc-avatax', '~> <version>'
```

#### 2) Configure the avatax plugin with the merchant's distribution center inside the host app `config/initializers/weblinc.rb` file.
```ruby
  Weblinc::Avatax.configure do |config|
    config.dist_center = {
      Line1: '1234 Your St',
      Line2: '',
      City: 'YourCity',
      Region: 'Your State',
      Country: 'US',
      PostalCode: '123456'
    }
  end
```
#### 3) Go to [your host app]/admin in the browser and set up your Avatax information in the Avatax settings.
![image of settings link](https://www.evernote.com/l/AaQPfWK2CHlDPbF5mK5bPSJdy0NakiJmZ0YB/image.png)

#### 4) Enter your configuration settings and save.
![Image of Avatax Settings page](https://www.evernote.com/l/AaTbJD0hcnRJsojw6UO1J4ubJEm-d2ciJA4B/image.png)

#### 5) Select test connection from either the settings screen or the settings menu.
![Image of Conntection Page](https://www.evernote.com/l/AaRrPIQFMR9AA7yNTFx4KOMtCx1ZkVT5IJ8B/image.png)
