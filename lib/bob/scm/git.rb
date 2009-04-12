module Bob
  module SCM
    class Git
      attr_reader :uri, :branch

      def initialize(uri, branch)
        @uri = Addressable::URI.parse(uri)
        @branch = branch
      end

      # Checkout the code into <tt>working_dir</tt> at the specified revision and
      # call the passed block
      def with_commit(commit_id)
        update_code
        checkout(commit_id)
        yield
      end

      # Get some information about the specified commit. Returns a hash with:
      #
      # [<tt>:author</tt>]       Commit author's name and email
      # [<tt>:message</tt>]      Commit message
      # [<tt>:committed_at</tt>] Commit date (as a <tt>Time</tt> object)
      def info(commit_id)
        format  = %Q(---%n:author: %an <%ae>%n:message: >-%n  %s%n:committed_at: %ci%n)
        YAML.load(`cd #{working_dir} && git show -s --pretty=format:"#{format}" #{commit_id}`).tap do |info|
          info[:committed_at] = Time.parse(info[:committed_at])
        end
      end

      # Directory where the code will be checked out. Make sure the user running Bob is
      # allowed to write to this directory (or you'll get a <tt>Errno::EACCESS</tt>)
      def working_dir
        @working_dir ||= "#{Bob.base_dir}/#{path_from_uri}".tap do |path|
          FileUtils.mkdir_p path
        end
      end

      private

      def update_code
        cloned? ? fetch : clone
      end

      def cloned?
        File.directory?("#{working_dir}/.git")
      end

      def clone
        run_command "git clone #{uri} #{working_dir}"
      rescue CantRunCommand
        FileUtils.rm_r working_dir
        retry
      end

      def fetch
        run_command "cd #{working_dir} && git fetch origin"
      end

      def checkout(commit_id)
        # First checkout the branch just in case the commit_id turns out to be HEAD or other non-sha identifier
        run_command "cd #{working_dir} && git checkout origin/#{branch} && git reset --hard #{commit_id}"
      end

      def path_from_uri
        path = uri.path.
          gsub(/\~[a-z0-9]*\//i, ""). # remove ~foobar/
          gsub(/\s+|\.|\//, "-").     # periods, spaces, slashes -> hyphens
          gsub(/^-+|-+$/, "")         # remove trailing hyphens
        path += "-#{branch}"
      end

      def run_command(cmd)
        Bob.logger.debug "Running git command: '#{cmd}'"
        system("(#{cmd}) &>/dev/null").tap do |successful|
          raise CantRunCommand, "Couldn't run '#{cmd}'" unless successful
        end
      end
    end
  end
end
