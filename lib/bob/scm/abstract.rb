module Bob
  module SCM
    class Abstract
      attr_reader :uri, :branch

      def initialize(uri, branch)
        @uri = Addressable::URI.parse(uri)
        @branch = branch
      end

      # Checkout the code into <tt>working_dir</tt> at the specified revision
      # and call the passed block
      def with_commit(commit_id)
        update_code
        checkout(commit_id)
        yield
      end

      # Directory where the code will be checked out. Make sure the user 
      # running Bob is allowed to write to this directory (or you'll get a 
      # <tt>Errno::EACCESS</tt>)
      def working_dir
        @working_dir ||= "#{Bob.directory}/#{path_from_uri}".tap do |path|
          FileUtils.mkdir_p path
        end
      end

      # Get some information about the specified commit. Returns a hash with:
      #
      # [<tt>:author</tt>]       Commit author's name and email
      # [<tt>:message</tt>]      Commit message
      # [<tt>:committed_at</tt>] Commit date (as a <tt>Time</tt> object)
      def info(commit_id)
        raise NotImplementedError
      end

      # Return the identifier for the last commit in this branch of the
      # repository.
      def head
        raise NotImplementedError
      end

      protected

      def run(command, cd_into_working_dir=true)
        command_prefix = cd_into_working_dir ? "cd #{working_dir} && " : ""
        command = "(#{command_prefix}#{command} &>/dev/null)"
        Bob.logger.debug command
        system(command) || raise(CantRunCommand, "Couldn't run SCM command `#{command}`")
      end

      def path_from_uri
        raise NotImplementedError
      end
    end
  end
end
