require File.dirname(__FILE__) + "/../helper"

class BobTest < Test::Unit::TestCase
  test "can build multiple commit_ids at a time" do
    mock(Builder).new(buildable, /a_commit|another_commit|and_another/).times(3) { stub!.build { nil }}
    Bob.build(buildable, "a_commit", "another_commit", "and_another")
  end
end
