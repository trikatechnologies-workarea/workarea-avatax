#!/usr/bin/env rake
begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"
require "rake/testtask"

require "rake/testtask"
Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end
task default: :test

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "workarea/avatax/version"

desc 'Generate the changelog based on git history'
task :changelog, :from, :to do |t, args|
  require 'date'

  from = args[:from] || `git describe --tags --abbrev=0`.strip
  to = args[:to] || 'HEAD'
  log = `git log #{from}..#{to} --pretty=format:'%an|%B___'`

  puts "Workarea Avatax #{Workarea::Avatax::VERSION} (#{Date.today})"
  puts '-' * 80
  puts

  log.split(/___/).each do |commit|
    pieces = commit.split('|').reverse
    author = pieces.pop.strip
    message = pieces.join.strip

    next if message =~ /^\s*Merge pull request/
    next if message =~ /No changelog/

    ticket = message.scan(/AVATAX-\d+/)[0]
    next if ticket.nil?
    next if message =~ /^\s*Merge branch/ && ticket.nil?

    first_line = false

    message.each_line do |line|
      if !first_line
        first_line = true
        puts "*   #{line}"
      elsif line.strip.empty?
        puts
      else
        puts "    #{line}"
      end
    end

    puts "    #{author}"
    puts
  end
end

desc "Release version #{Workarea::Avatax::VERSION} of the gem"
task :release do
  host = "https://#{ENV['BUNDLE_GEMS__WEBLINC__COM']}@gems.weblinc.com"

  system 'touch CHANGELOG.md'
  system 'echo "$(rake changelog)\n\n\n$(cat CHANGELOG.md)" > CHANGELOG.md'
  system 'git add CHANGELOG.md && git commit -m "Update changelog" && git push origin head'

  system "git tag -a v#{Workarea::Avatax::VERSION} -m 'Tagging #{Workarea::Avatax::VERSION}'"
  system "git push --tags"

  system "gem build workarea-avatax.gemspec"
  system "gem push workarea-avatax-#{Workarea::Avatax::VERSION}.gem --host #{host}"
  system "rm workarea-avatax-#{Workarea::Avatax::VERSION}.gem"
end
