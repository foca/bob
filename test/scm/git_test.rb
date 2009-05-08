require File.dirname(__FILE__) + "/../helper"

class BobGitTest < Test::Unit::TestCase
  def setup
    super

    @repo = GitRepo.new(:test_repo)
    @repo.create

    @buildable = GitBuildableStub.new(@repo)
  end

  test "with a successful build" do
    repo.add_successful_commit

    commit_id = repo.commits.last[:identifier]

    buildable.build(commit_id)

    status, output = buildable.builds[commit_id]
    assert_equal :successful,          status
    assert_equal "Running tests...\n", output

    assert_equal 1, buildable.metadata.length

    commit = buildable.metadata[commit_id]
    assert_equal "This commit will work", commit[:message]
    assert_equal Time.now.min,            commit[:committed_at].min
  end

  test "with a failed build" do
    repo.add_failing_commit

    commit_id = repo.commits.last[:identifier]

    buildable.build(commit_id)

    status, output = buildable.builds[commit_id]
    assert_equal :failed,              status
    assert_equal "Running tests...\n", output

    assert_equal 1, buildable.metadata.length

    commit = buildable.metadata[commit_id]
    assert_equal "This commit will fail", commit[:message]
    assert_equal Time.now.min,            commit[:committed_at].min
  end

  test "with multiple commits" do
    2.times { repo.add_failing_commit }
    commits = repo.commits.collect { |c| c[:identifier] }

    buildable.build(commits)

    assert_equal 2, commits.length
    assert_equal 2, buildable.metadata.length
    assert_equal 2, buildable.builds.length
  end
end
