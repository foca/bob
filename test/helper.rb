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
Bob.background_engine = Bob::BackgroundEngines::Foreground
Bob.base_dir = File.expand_path(File.dirname(__FILE__) + "/tmp/")

module TestHelpers
  class StubBuildable
    def initialize(repo_name)
      @repo = GitHelper.git_repo(repo_name)
    end

    def repo_kind
      :git
    end

    def repo_uri
      @repo.path
    end

    def repo_branch
      "master"
    end

    def build_script
      "./test"
    end

    def start_building(commit_id, commit_info)
    end

    def add_successful_build(commit_id, output)
    end

    def add_failed_build(commit_id, output)
    end
  end

  def buildable
    @buildable ||= StubBuildable.new(:test_repo)
  end

  def reset_build_directory!
    FileUtils.rm_rf Bob.base_dir if File.directory? Bob.base_dir
    FileUtils.mkdir_p Bob.base_dir
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
