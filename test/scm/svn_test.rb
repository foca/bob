require File.dirname(__FILE__) + "/../helper"

class BobSvnTest < Test::Unit::TestCase
  def setup
    super

    @repo = SvnRepo.new(:test_repo)
    @repo.create

    @buildable = SvnBuildableStub.new(@repo)
  end

  def path(uri)
    SCM::Svn.new(uri, "").__send__(:path)
  end

  test "converts svn repo uri into a path" do
    assert_equal "http-rubygems-rubyforge-org-svn",
      path("http://rubygems.rubyforge.org/svn/")

    assert_equal "svn-rubyforge-org-var-svn-rubygems",
      path("svn://rubyforge.org/var/svn/rubygems")

    assert_equal "svn-ssh-developername-rubyforge-org-var-svn-rubygems",
      path("svn+ssh://developername@rubyforge.org/var/svn/rubygems")

    assert_equal "home-user-code-repo",
      path("/home/user/code/repo")
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
