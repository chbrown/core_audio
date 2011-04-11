# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "core_audio/version"

Gem::Specification.new do |s|
  s.name        = "core_audio"
  s.version     = CoreAudio::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeremy Voorhis"]
  s.email       = ["jvoorhis@gmail.com"]
  s.homepage    = "https://github.com/jvoorhis/core_audio"
  s.summary     = %q{CoreAudio bindings for Ruby}
  s.description = %q{CoreAudio bindings for Ruby, really}

  s.rubyforge_project = "core_audio"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
