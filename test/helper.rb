require "test/unit"
require "contest"
require "hpricot"

begin
  require "redgreen"
  require "ruby-debug"
rescue LoadError
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"),
  File.expand_path(File.dirname(__FILE__) + "/../test/helper"))

require "bob"
require "bob/test"

class Test::Unit::TestCase
  include Bob
  include Bob::Test

  attr_reader :repo

  def setup
    Bob.logger = Logger.new("/dev/null")
    Bob.engine = Bob::Engine::Foreground
    Bob.directory = File.expand_path(File.dirname(__FILE__) + "/../tmp")

    FileUtils.rm_rf(Bob.directory) if File.directory?(Bob.directory)
  end

  BuildableStub = Struct.new(:scm, :uri, :branch, :commit, :build_script) do
    include Bob::Buildable

    attr_reader :repo, :builds, :metadata

    def self.call(repo, commit)
      scm = (Bob::Test::GitRepo === repo) ? :git : :svn
      uri =
        if scm == :git
          repo.path
        else
          "file://#{SvnRepo.server_root}/#{repo.name}"
        end
      # move to repo
      branch = (scm == :git) ? "master" : ""
      build_script = "./test"

      new(scm, uri, branch, commit, build_script)
    end

    def initialize(*args)
      super

      @builds   = {}
      @metadata = {}
    end

    def start_building(commit_id, commit_info)
      @metadata[commit_id] = commit_info
    end

    def finish_building(commit_id, status, output)
      @builds[commit_id] = [status ? :successful : :failed, output]
    end
  end

end
