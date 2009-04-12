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

Bob.logger = Logger.new("/dev/null")
Bob.engine = Bob::BackgroundEngines::Foreground
Bob.directory = File.expand_path(File.dirname(__FILE__) + "/tmp/")

module TestHelpers
  class StubBuildable
    attr_reader :builds, :metadata

    def initialize(repo_name)
      @repo = GitHelper.git_repo(repo_name)
      @builds = {}
      @metadata = {}
    end

    def kind
      :git
    end

    def uri
      @repo.path
    end

    def branch
      "master"
    end

    def build_script
      "./test"
    end

    def start_building(commit_id, commit_info)
      @metadata[commit_id] = commit_info
    end

    def finish_building(commit_id, status, output)
      @builds[commit_id] = [status ? :successful : :failed, output]
    end
  end

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
