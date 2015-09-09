require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |test|
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = false
end

task :console do
  exec "irb -r fit-commit -I ./lib"
end

task default: :test
