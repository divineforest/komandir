# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "komandir/version"

Gem::Specification.new do |s|
  s.name        = "komandir"
  s.version     = Komandir::VERSION
  s.authors     = ["divineforest"]
  # s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Authenticate user using eToken}
  # s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "komandir"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
