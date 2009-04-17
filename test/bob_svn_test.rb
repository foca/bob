require File.dirname(__FILE__) + "/helper"

class BobSvnTest < Test::Unit::TestCase
  attr_accessor :repo, :buildable

  def setup
    SvnRepo.start_server

    # FIXME
    FileUtils.rm_rf "/tmp/svn-test_repo"

    @repo = SvnRepo.new(:test_repo)
    @repo.destroy
    @repo.create

    @buildable = SvnBuildableStub.new(@repo)
  end

  def teardown
    @repo.destroy

    sleep 0.5
    SvnRepo.stop_server
  end

  test "with a successful build" do
    @repo.add_successful_commit

    Bob.build(buildable, "2")

    assert_equal 1, buildable.metadata.length

    status, output = buildable.builds["2"]
    assert_equal :successful,          status
    assert_equal "Running tests...\n", output

    assert_equal 1, buildable.metadata.length

    commit = buildable.metadata["2"]
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

    assert_equal 1, buildable.metadata.length

    commit = buildable.metadata[commit_id]
    assert_equal "This commit will fail", commit[:message]
    assert_equal Time.now.min,            commit[:committed_at].min
  end

  test "with multiple commits" do
    repo.add_successful_commit
    2.times { repo.add_failing_commit }

    Bob.build(buildable, repo.commits.collect { |c| c[:identifier] })

    assert_equal 3, buildable.metadata.length
    assert_equal 3, buildable.builds.length
  end
end
