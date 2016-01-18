#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
RSpec::Core::RakeTask.new

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'weblinc/avatax/version'

desc "Release version #{Weblinc::Avatax::VERSION} of the gem"
task :release do
  host = "https://#{ENV['BUNDLE_GEMS__WEBLINC__COM']}@gems.weblinc.com"

  system "git tag -a v#{Weblinc::Avatax::VERSION} -m 'Tagging #{Weblinc::Avatax::VERSION}'"
  system 'git push --tags'

  system "gem build weblinc-paypal.gemspec"
  system "gem push weblinc-paypal-#{Weblinc::Avatax::VERSION}.gem --host #{host}"
  system "rm weblinc-paypal-#{Weblinc::Avatax::VERSION}.gem"
end
