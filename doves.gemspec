# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doves/version'

Gem::Specification.new do |spec|
  spec.name          = "doves"
  spec.version       = Doves::VERSION
  spec.authors       = ["Chase McCarthy"]
  spec.email         = ["chase@code0100fun.com"]
  spec.description   = %q{Plays a persons theme music when they enter the room}
  spec.summary       = %q{Watches for a persons cell phone to join the network then plays the song they selected as their theme music}
  spec.homepage      = "https://github.com/code0100fun/doves"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "spotify"
  spec.add_development_dependency "plaything"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "ffi-pcap"
  spec.add_development_dependency "ffi-packets"
  spec.add_development_dependency "redis"
end
