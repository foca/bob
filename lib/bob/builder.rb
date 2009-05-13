module Bob
  # A Builder will take care of building a buildable (wow, you didn't see that coming,
  # right?).
  class Builder
    attr_reader :buildable

    # Instantiate the Builder, passing an object that understands the <tt>Buildable</tt>
    # interface, and a <tt>commit_id</tt>.
    #
    # You can pass <tt>:head</tt> as the commit id, in which case it will resolve to the
    # head commit of the current branch (for example, "HEAD" under git, or the latest
    # revision under svn)
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
          build_status, build_output = run_build_script
          buildable.finish_building(commit_id, build_status, build_output)
        end
      end
    end

    private

    def commit_id
      @commit_id == :head ? scm.head : @commit_id
    end

    def run_build_script
      build_output = nil

      Bob.logger.debug "Running the build script for #{buildable.uri}"
      IO.popen(build_script, "r") { |output| build_output = output.read }
      Bob.logger.debug("Ran build script `#{build_script}` and got:\n#{build_output}")

      [$?.success?, build_output]
    end

    def build_script
      "(cd #{scm.working_dir} && #{buildable.build_script} 2>&1)"
    end

    def scm
      @scm ||= SCM.new(buildable.kind, buildable.uri, buildable.branch)
    end

    def in_background(&block)
      Bob.engine.call(block)
    end
  end
end
