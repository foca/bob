require "test/unit"
require "contest"
require "hpricot"

begin
  require "redgreen"
rescue LoadError
end

if ENV["DEBUG"]
  require "ruby-debug"
else
  def debugger
    puts "Run your tests with DEBUG=1 to use the debugger"
  end
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"),
                   File.expand_path(File.dirname(__FILE__) + "/../test/helper"))

require "bob"
require "git_helper"
require "svn_helper"
require "buildable_stub"


class Test::Unit::TestCase
  include Bob
  include TestHelper

  attr_reader :repo, :buildable

  def setup
    Bob.logger = Logger.new("/dev/null")
    Bob.engine = Bob::BackgroundEngines::Foreground
    Bob.directory = File.expand_path(File.dirname(__FILE__) + "/../tmp")

    FileUtils.rm_rf(Bob.directory) if File.directory?(Bob.directory)
  end
end
