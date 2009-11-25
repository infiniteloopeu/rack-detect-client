Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.name              = "rack-detect-client"
  s.version           = "0.1.0"
  s.date              = "2009-10-13"
  s.summary           = "Detects client capabilities (like mobile, iphone or w/e)."
  s.description       = "Detects client capabilities (like mobile, iphone or w/e)."
  s.authors           = ["Jakub Straszewski"]
  s.email             = "jakub.straszewski@infiniteloop.eu"
  s.homepage          = "http://github.com/jstrasze/rack-detect-client"
  s.files             = ["Rakefile", "README", "lib/rack/detect_client.rb"]
  s.test_files        = ["test/detect_client_test.rb"]
  s.rubygems_version  = "1.3.5"
  s.add_dependency 'rack', '1.0'
end
