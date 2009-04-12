require "rake/testtask"

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
