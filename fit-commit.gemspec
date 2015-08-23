# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fit-commit}
  s.version = "1.0.0"

  s.authors = ["Mike Foley"]
  s.default_executable = %q{fit-commit}
  s.email = %q{dontneedmoreemail@example.com}
  s.executables = ["fit-commit"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir["bin/*", "lib/**/*", "templates/**/*"]
  s.homepage = %q{http://github.com/m1foley/fit-commit}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.summary = "Validate your Git commit messages"
  s.description = "A Git commit-msg hook to validate your Git commit messages"
  s.post_install_message == <<-EOF
    Thank you for installing fit-commit!
    Install the hook in each git repo you want to scan using:

    > fit-commit install

    Read more: https://github.com/m1foley/fit-commit#readme
  EOF
end
