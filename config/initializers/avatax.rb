
# swap default tax calculator for AvaTax
Weblinc::Pricing.calculators.swap(
  Weblinc::Pricing::Calculators::TaxCalculator,
  Weblinc::Pricing::Calculators::AvalaraTaxCalculator
)
