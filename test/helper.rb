require "test/unit"
require "contest"
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
require "buildable_stub"

Bob.logger = Logger.new("/dev/null")
Bob.engine = Bob::BackgroundEngines::Foreground
Bob.directory = File.expand_path(File.dirname(__FILE__) + "/tmp/")

class Test::Unit::TestCase
  include GitHelper
  include Bob

  attr_accessor :buildable, :repo

  setup do
    FileUtils.rm_rf Bob.directory if File.directory?(Bob.directory)
    FileUtils.mkdir_p Bob.directory
  end
end
