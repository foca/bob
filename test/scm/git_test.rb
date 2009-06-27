require File.dirname(__FILE__) + "/../helper"

class BobGitTest < Test::Unit::TestCase
  def setup
    super

    @repo = GitRepo.new(:test_repo)
    @repo.create

    @buildable = BuildableStub.from(@repo)
  end

  def path(uri, branch="master")
    SCM::Git.new(uri, branch).__send__(:path)
  end

  test "converts repo uri into a path" do
    assert_equal "git-github-com-integrity-bob-master",
      path("git://github.com/integrity/bob")
    assert_equal "git-example-org-foo-repo-master",
      path("git@example.org:~foo/repo")
    assert_equal "tmp-repo-git-master", path("/tmp/repo.git")
    assert_equal "tmp-repo-git-foo",    path("/tmp/repo.git", "foo")
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
    assert commit[:committed_at].is_a?(Time)
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
    assert commit[:committed_at].is_a?(Time)
  end

  test "with multiple commits" do
    2.times { repo.add_failing_commit }
    commits = repo.commits.collect { |c| c[:identifier] }

    buildable.build(commits)

    assert_equal 2, commits.length
    assert_equal 2, buildable.metadata.length
    assert_equal 2, buildable.builds.length
  end

  test "can build the head of a repository" do
    repo.add_failing_commit
    repo.add_successful_commit

    buildable.build(:head)

    assert_equal 1, buildable.builds.length

    status, output = buildable.builds[repo.head]
    assert_equal :successful,          status
    assert_equal "Running tests...\n", output
  end
end
