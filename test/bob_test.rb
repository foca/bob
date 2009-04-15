require File.dirname(__FILE__) + "/helper"

class BobTest < Test::Unit::TestCase
  describe "Building a git repository" do
    attr_accessor :repo, :commit_id, :buildable

    setup do
      @repo      = git_repo(:test_repo)
      @repo.create
      @commit_id = repo.commits.first[:identifier]
      @buildable = StubBuildable.new(@repo)
    end

    test "with a successful build" do
      Bob.build(buildable, commit_id)

      status, output = buildable.builds[commit_id]
      assert_equal :successful,          status
      assert_equal "Running tests...\n", output

      commit = buildable.metadata[commit_id]
      assert_equal "This commit will work", commit[:message]
      assert_equal Time.now.min,            commit[:committed_at].min
    end

    test "with a failed build" do
      repo.add_failing_commit
      commit_id = repo.commits.first[:identifier]

      Bob.build(buildable, commit_id)

      status, output = buildable.builds[commit_id]
      assert_equal :failed,              status
      assert_equal "Running tests...\n", output

      commit = buildable.metadata[commit_id]
      assert_equal "This commit will fail", commit[:message]
      assert_equal Time.now.min,            commit[:committed_at].min
    end

    test "with multiple commits" do
      2.times { repo.add_failing_commit }
      commits = repo.commits.collect { |c| c[:identifier] }
      Bob.build(buildable, commits)

      assert_equal 3, buildable.metadata.length
      assert_equal 3, buildable.builds.length
    end
  end
end
