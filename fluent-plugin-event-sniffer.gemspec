# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-event-sniffer"
  spec.version       = "0.0.1"
  spec.authors       = ["OKUNO Akihiro"]
  spec.email         = ["choplin.choplin@gmail.com"]
  spec.summary       = %q{Fluentd Event Sniffer}
  spec.description   = %q{Fluentd plugin which serves web application sniffing streaming events}
  spec.homepage      = "https://github.com/choplin/fluent-plugin-event-sniffer"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0") + Dir['public/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "sinatra-rocketio"
  spec.add_runtime_dependency "thin"
  spec.add_runtime_dependency "slim"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sinatra-contrib"
  spec.add_development_dependency "foreman"
  spec.add_development_dependency "dummer"
end
