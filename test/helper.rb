require "test/unit"
require "contest"
require "rr"
require "ostruct"

begin
  require "redgreen"
  require "ruby-debug"
rescue LoadError
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"),
                   File.expand_path(File.dirname(__FILE__) + "/../test/helper"))

require "bob"
require "git_helper"
require "stub_buildable"

Bob.logger = Logger.new("/dev/null")
Bob.engine = Bob::BackgroundEngines::Foreground
Bob.directory = File.expand_path(File.dirname(__FILE__) + "/tmp/")

module TestHelpers
  def buildable
    @buildable ||= StubBuildable.new(:test_repo)
  end

  def reset_build_directory!
    FileUtils.rm_rf Bob.directory if File.directory?(Bob.directory)
    FileUtils.mkdir_p Bob.directory
  end
end

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  include TestHelpers
  include GitHelper
  include Bob

  setup do
    reset_build_directory!
  end
end
