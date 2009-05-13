require File.dirname(__FILE__) + "/../helper"

class BobSvnTest < Test::Unit::TestCase
  def setup
    super

    @repo = SvnRepo.new(:test_repo)
    @repo.create

    @buildable = SvnBuildableStub.new(@repo)
  end

  test "with a successful build" do
    repo.add_successful_commit

    buildable.build("2")

    assert_equal 1, buildable.metadata.length

    status, output = buildable.builds["2"]
    assert_equal :successful,          status
    assert_equal "Running tests...\n", output

    assert_equal 1, buildable.metadata.length

    commit = buildable.metadata["2"]
    assert commit[:committed_at].is_a?(Time)
    assert_equal "This commit will work", commit[:message]
  end

  test "with a failed build" do
    repo.add_failing_commit
    commit_id = repo.commits.first[:identifier]

    buildable.build(commit_id)

    status, output = buildable.builds[commit_id]
    assert_equal :failed,              status
    assert_equal "Running tests...\n", output

    assert_equal 1, buildable.metadata.length

    commit = buildable.metadata[commit_id]
    assert commit[:committed_at].is_a?(Time)
    assert_equal "This commit will fail", commit[:message]
  end

  test "with multiple commits" do
    repo.add_successful_commit
    2.times { repo.add_failing_commit }

    buildable.build(repo.commits.collect { |c| c[:identifier] })

    assert_equal 3, buildable.metadata.length
    assert_equal 3, buildable.builds.length
  end

  test "can build the head of a repository" do
    repo.add_failing_commit
    repo.add_successful_commit

    buildable.build(:head)

    assert_equal 1, buildable.builds.length

    status, output = buildable.builds["3"]
    assert_equal :successful,          status
    assert_equal "Running tests...\n", output
  end
end
