module Bob
  # A Builder will take care of building a buildable (wow, you didn't see that coming,
  # right?).
  class Builder
    def initialize(buildable, commit_id)
      @buildable = buildable
      @commit_id = commit_id
      @build_output = nil
    end

    # This is where the magic happens: 
    #
    # 1. Check out the repo to the appropriate commit.
    # 2. Run the build script on it in the background.
    # 3. Reports the build back to the buildable.
    def build
      Bob.logger.info "Building #{commit_id} of the #{buildable.repo_kind} repo at #{buildable.repo_uri}"
      in_background do
        scm.with_commit(commit_id) do
          buildable.start_building(commit_id, scm.info(commit_id))
          report_build run_build_script
        end
      end
    end

    private

    attr_reader :buildable, :commit_id, :build_output

    def scm
      @scm ||= SCM.new(buildable.repo_kind, buildable.repo_uri, buildable.repo_branch)
    end

    def run_build_script
      Bob.logger.debug "Running the build script for #{buildable.repo_uri}"

      IO.popen("(cd #{scm.working_dir} && #{buildable.build_script} 2>&1)", "r") do |output| 
        @build_output = output.read
      end

      Bob.logger.debug("Ran command '(cd #{scm.working_dir} && #{buildable.build_script} 2>&1)' and got:\n#{build_output}")
      $?.success?
    end

    def report_build(status)
      if status
        buildable.add_successful_build(commit_id, build_output)
      else
        buildable.add_failed_build(commit_id, build_output)
      end
    end

    def in_background(&block)
      Bob.background_engine.call(block)
    end
  end
end
