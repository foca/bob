require File.dirname(__FILE__) + "/../helper"

class ThreadedBobTest < Test::Unit::TestCase
  def setup
    super

    @repo = GitRepo.new(:test_repo)
    @repo.create
  end

  test "with a successful threaded build" do
    old_engine = Bob.engine

    repo.add_successful_commit
    commit_id = repo.commits.last[:identifier]
    buildable = BuildableStub.call(@repo, commit_id)

    begin
      Thread.abort_on_exception = true
      Bob.engine = Bob::Engine::Threaded.new(5)
      buildable.build
      Bob.engine.wait!

      status, output = buildable.builds[commit_id]
      assert_equal :successful,          status
      assert_equal "Running tests...\n", output

      commit = buildable.metadata[commit_id]
      assert_equal "This commit will work", commit[:message]
      assert_equal Time.now.min,            commit[:committed_at].min
    ensure
      Bob.engine = old_engine
    end
  end
end
