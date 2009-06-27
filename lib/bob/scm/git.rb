module Bob
  module SCM
    class Git < Abstract
      def info(commit_id)
        format  = %Q(---%n:author: %an <%ae>%n:message: >-%n  %s%n:committed_at: %ci%n)
        YAML.load(`cd #{working_dir} && git show -s --pretty=format:"#{format}" #{commit_id}`).tap { |info|
          info[:committed_at] = Time.parse(info[:committed_at])
        }
      end

      def head
        `git ls-remote --heads #{uri} #{branch} | cut -f1`.chomp
      end

      private

      def update_code
        cloned? ? fetch : clone
      end

      def cloned?
        File.directory?("#{working_dir}/.git")
      end

      def clone
        run "git clone #{uri} #{working_dir}", false
      end

      def fetch
        git "fetch origin"
      end

      def checkout(commit_id)
        # First checkout the branch just in case the commit_id turns out to be HEAD or other non-sha identifier
        git "checkout origin/#{branch}"
        git "reset --hard #{commit_id}"
      end

      def git(command)
        run "git #{command}"
      end
    end
  end
end
