Weblinc::Pricing.class_eval do
puts "MRA calculators.class", self.calculators.class
puts "MRA calculators.inspect", self.calculators.inspect
  self.calculators.swap( 
   Weblinc::Pricing::Calculators::TaxCalculator, 
   Weblinc::Pricing::Calculators::AvalaraTaxCalculator)
puts "MRA calculators.inspect", self.calculators.inspect
end
