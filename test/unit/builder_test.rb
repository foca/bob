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
    mock.proxy(buildable).start_building(commit_id, hash_including(
      :author => "John Doe <johndoe@example.org>",
      :message => "This commit will work"
    ))
    builder.build
  end

  test "it calls #add_successful_build on the buildable after a successful build" do
    git_repo(:test_repo).add_successful_commit
    mock.proxy(buildable).add_successful_build(commit_id, "Running tests...\n")
    builder.build
  end

  test "it calls #add_failed_build on the buildable after a failed build" do
    git_repo(:test_repo).add_failing_commit
    mock.proxy(buildable).add_failed_build(commit_id, "Running tests...\n")
    builder.build
  end
end
