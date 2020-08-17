Gem::Specification.new do |s|
  # Metadata.
  s.name          = "logstash-output-wavefront"
  s.version       = "1.0.1"
  s.licenses      = ["Apache-2.0"]
  s.summary       = "Logstash plugin for sending data to Wavefront."
  s.description   = "This gem is a Logstash plugin required to be installed "\
                    "on top of the Logstash core pipeline using "\
                    "$LS_HOME/bin/logstash-plugin install gemname. "\
                    "This gem is not a stand-alone program."
  s.authors       = ["Wavefront"]
  s.email         = "help@wavefront.com"
  s.homepage      = "https://www.wavefront.com/"

  # Package contents.
  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*",
                "spec/**/*",
                "vendor/**/*",
                "*.gemspec",
                "*.md",
                "Gemfile",
                "LICENSE"]
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", "~> 7.5", ">= 7.5.2"
  s.add_runtime_dependency "logstash-codec-plain", "~> 3.0", ">= 3.0.6"
  s.add_runtime_dependency "wavefront-client", "~> 3.6", ">= 3.6.2"
  s.add_development_dependency "logstash-devutils", "~> 2.0", ">= 2.0.3"
end
