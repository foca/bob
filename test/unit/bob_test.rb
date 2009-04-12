require File.dirname(__FILE__) + "/../helper"

class BobTest < Test::Unit::TestCase
  test "can build multiple commit_ids at a time" do
    mock(Builder).new(buildable, /a_commit|another_commit|and_another/).times(3) { stub!.build { nil }}
    Bob.build(buildable, "a_commit", "another_commit", "and_another")
  end

  test "fails if it doesn't get any commit_id" do
    assert_raises ArgumentError do
      Bob.build(buildable)
    end
  end
end
