require File.dirname(__FILE__) + "/../helper"

class BuilderTest < Test::Unit::TestCase
  def builder
    @builder ||= Builder.new(buildable, commit_id)
  end

  def commit_id
    git_repo(:test_repo).head
  end

  test "it calls #start_building with the commit_id and the commit info" do
    git_repo(:test_repo).add_successful_commit
    builder.build

    assert_equal "John Doe <johndoe@example.org>", buildable.metadata[commit_id][:author]
    assert_equal "This commit will work",          buildable.metadata[commit_id][:message]
    assert       buildable.metadata[commit_id][:committed_at].is_a?(Time)
  end

  test "it calls #add_build (:successful) on the buildable after a successful build" do
    git_repo(:test_repo).add_successful_commit
    builder.build

    assert_equal [:successful, "Running tests...\n"], buildable.builds[commit_id]
  end

  test "it calls #add_build (:failed) on the buildable after a failed build" do
    git_repo(:test_repo).add_failing_commit
    builder.build

    assert_equal [:failed, "Running tests...\n"], buildable.builds[commit_id]
  end
end
