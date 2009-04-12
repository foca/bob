require "rake/testtask"
require "rake/rdoctask"

begin
  require "metric_fu"
rescue LoadError
end

begin
  require "mg"
  MG.new("bob.gemspec")
rescue LoadError
end

desc "Default: run all tests"
task :default => :test

desc "Run unit tests"
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/unit/*_test.rb"]
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  rd.rdoc_dir = "doc"
end
