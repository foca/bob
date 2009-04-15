class StubBuildable
  attr_reader :builds, :metadata

  def initialize(repo)
    @repo     = repo
    @builds   = {}
    @metadata = {}
  end

  def kind
    :git
  end

  def uri
    @repo.path
  end

  def branch
    "master"
  end

  def build_script
    "./test"
  end

  def start_building(commit_id, commit_info)
    @metadata[commit_id] = commit_info
  end

  def finish_building(commit_id, status, output)
    @builds[commit_id] = [status ? :successful : :failed, output]
  end
end
