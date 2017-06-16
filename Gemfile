source "https://rubygems.org"
source "https://gems.weblinc.com"

gemspec
gem "rubocop", "~> 0.48", require: false
gem "bundler-audit", require: false

# TODO wait for ECOMMERCE-4819 to be released
gem "workarea",
  git: "ssh://git@stash.tools.weblinc.com:7999/wl/workarea.git",
  branch: "v3.0-stable"

group :test do
  gem "simplecov"
end
