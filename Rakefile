require "rake/testtask"
require "rake/rdoctask"

begin
  require "metric_fu"
rescue LoadError
end

desc "Default: run all tests"
task :default => :test

desc "Run unit tests"
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/unit/*_test.rb"]
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "doc"
end
