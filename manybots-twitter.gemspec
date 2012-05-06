$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "manybots-twitter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "manybots-twitter"
  s.version     = ManybotsTwitter::VERSION
  s.authors     = ["Niko Roberts"]
  s.email       = ["niko@manybots.com"]
  s.homepage    = "https://github.com/manybots/manybots-twitter"
  s.summary     = "A Twitter observer for all your Twitter activity."
  s.description = "Import all of your Twitter activity to your local Manybots."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  # s.add_dependency "jquery-rails"
  s.add_dependency "twitter"

  s.add_development_dependency "sqlite3"
end
