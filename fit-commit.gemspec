# -*- encoding: utf-8 -*-
require File.expand_path("../lib/fit_commit/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name               = "fit-commit"
  gem.version            = FitCommit::VERSION
  gem.license            = "MIT"
  gem.authors            = ["Michael Foley"]
  gem.email              = ["foley3@gmail.com"]
  gem.homepage           = "https://github.com/m1foley/fit-commit"
  gem.summary            = "A Git hook to validate your commit messages"
  gem.description        = "A Git hook to validate your commit messages based on community standards."
  gem.files              = `git ls-files`.split("\n")
  gem.executables        = ["fit-commit"]
  gem.test_files         = `git ls-files -- test/*`.split("\n")
  gem.require_paths      = ["lib"]
  gem.extra_rdoc_files   = ["README.md"]
  gem.rdoc_options       = ["--main", "README.md"]

  gem.post_install_message = <<-EOF
    Thank you for installing Fit Commit!
    Install the hook in each git repo you want to scan using:

    > fit-commit install

    Read more: https://github.com/m1foley/fit-commit#readme
  EOF

  gem.add_dependency("swearjar", "~> 1.3")
  gem.add_development_dependency("minitest", "~> 5.11")
  gem.add_development_dependency("rake", "~> 12.3")
end
