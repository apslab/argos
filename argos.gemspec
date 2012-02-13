$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "argos/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "argos"
  s.version     = Argos::VERSION
  s.authors     = ["Maximiliano Dello Russo"]
  s.email       = ["maxidr@gmail.com"]
  #s.homepage    = "TODO"
  s.summary     = "SSO + Seguridad para los WS Rest"
  #s.description = "TODO: Description of Argos."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.1.3"
  s.add_dependency 'omniauth'
  s.add_dependency 'omniauth-oauth2'
  s.add_dependency 'rest-client'
  s.add_dependency 'oauth'
  # s.add_dependency "jquery-rails"


  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'rest-client'
  s.add_development_dependency 'omniauth'
  s.add_development_dependency 'oauth'
end
