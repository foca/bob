require "bob/scm/abstract"

module Bob
  module SCM
    class Svn < Abstract
      def info(revision)
        dump = %x[svn log --non-interactive --revision #{revision} #{uri}].split("\n")
        meta = dump[1].split(" | ")

        { :message => dump[3],
          :author  => meta[1],
          :committed_at => Time.parse(meta[2]) }
      end

      def head
        %x[svn info #{uri}].split("\n").detect {|line| line =~ /^Revision: (\d+)/ }
        $1.to_s
      end

      def with_commit(commit_id)
        update_code
        checkout(commit_id)
        yield
      end

    protected

      def path_from_uri
        "svn-#{uri.path[1..-1]}"
      end

    private

      def update_code
        initial_checkout unless checked_out?
      end

      def checkout(revision)
        run("svn up -q -r#{revision}")
      end

      def initial_checkout(revision=nil)
        run("svn co -q #{uri} #{working_dir}")
      end

      def checked_out?
        File.directory?(working_dir + "/.svn")
      end
    end
  end
end
