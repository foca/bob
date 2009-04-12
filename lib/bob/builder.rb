module Bob
  # A Builder will take care of building a buildable (wow, you didn't see that coming,
  # right?).
  class Builder
    attr_reader :buildable, :commit_id

    def initialize(buildable, commit_id)
      @buildable = buildable
      @commit_id = commit_id
    end

    # This is where the magic happens:
    #
    # 1. Check out the repo to the appropriate commit.
    # 2. Notify the buildable that the build is starting.
    # 3. Run the build script on it in the background.
    # 4. Reports the build back to the buildable.
    def build
      Bob.logger.info "Building #{commit_id} of the #{buildable.kind} repo at #{buildable.uri}"
      in_background do
        scm.with_commit(commit_id) do
          buildable.start_building(commit_id, scm.info(commit_id))
          build_status, build_output = run_command
          buildable.finish_building(commit_id, build_status, build_output)
        end
      end
    end

    private

    def scm
      @scm ||= SCM.new(buildable.kind, buildable.uri, buildable.branch)
    end

    def in_background(&block)
      Bob.background_engine.call(block)
    end

    def run_command
      build_output = nil

      Bob.logger.debug "Running the build script for #{buildable.uri}"
      IO.popen(command, "r") { |output| build_output = output.read }
      Bob.logger.debug("Ran command `#{command}` and got:\n#{build_output}")

      [$?.success?, build_output]
    end

    def command
      "(cd #{scm.working_dir} && #{buildable.command} 2>&1)"
    end
  end
end
