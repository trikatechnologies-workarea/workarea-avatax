#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'weblinc/rake_tasks'
require 'ci/reporter/rake/rspec'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'weblinc/avatax/version'

desc "Release version #{Weblinc::Avatax::VERSION} of the gem"
task :release do
  host = "https://#{ENV['WEBLINC_GEM_USERNAME']}:#{ENV['WEBLINC_GEM_PASSWORD']}@#{ENV['WEBLINC_GEM_HOST']}"

  system "git tag -a v#{Weblinc::Avatax::VERSION} -m 'Tagging #{Weblinc::Avatax::VERSION}'"
  system 'git push --tags'

  system "gem build weblinc-avatax.gemspec"
  system "gem push weblinc-avatax-#{Weblinc::Avatax::VERSION}.gem --host #{host}"
  system "rm weblinc-avatax-#{Weblinc::Avatax::VERSION}.gem"
end
