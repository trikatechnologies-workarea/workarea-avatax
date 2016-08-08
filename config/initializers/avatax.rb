if Rails.env.test?
  Weblinc::Pricing.calculators.swap(
    Weblinc::Pricing::Calculators::AvalaraTaxCalculator,
    Weblinc::Pricing::Calculators::TaxCalculator
  )
  # This will effectively disable the listener that publishes
  # transactions to Avatax.
  Weblinc::Avatax::Setting.current.update_attribute(:doc_handling, :none)
else
  Weblinc::Avatax::Setting.current.update_attributes!(
    Weblinc.config.avatax
  )
end
