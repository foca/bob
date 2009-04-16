require File.dirname(__FILE__) + "/helper"

class SVNHelperTest < Test::Unit::TestCase
  def setup
    SVNRepo.start_server

    @repo = SVNRepo.new(:test_repo)
    @repo.create
  end

  def teardown
    sleep 2
    SVNRepo.stop_server
  end

  test "it works, even if SVN is PITA" do
    assert_equal 1,              @repo.commits.length

    assert_equal 1,              @repo.head.to_i
    assert_equal 1,              @repo.commits.first[:identifier].to_i
    assert_equal "First commit", @repo.commits.first[:message]
    assert @repo.commits.first[:committed_at].is_a?(Time)
  end
end
