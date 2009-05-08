module TestHelper
  module BuildableStub
    include Bob::Buildable

    attr_reader :repo, :builds, :metadata

    def initialize(repo)
      @repo     = repo
      @builds   = {}
      @metadata = {}
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

  class GitBuildableStub
    include BuildableStub

    def kind
      :git
    end

    def uri
      repo.path
    end

    def branch
      "master"
    end
  end

  class SvnBuildableStub
    include BuildableStub

    def kind
      :svn
    end

    def uri
      "file://#{SvnRepo.server_root}/#{repo.name}"
    end

    def branch
      ""
    end
  end
end
