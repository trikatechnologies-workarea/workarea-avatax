
# swap default tax calculator for AvaTax
Weblinc::Pricing.shipment_calculators.swap(
  Weblinc::Pricing::Calculators::TaxCalculator,
  Weblinc::Pricing::Calculators::AvalaraTaxCalculator
)
