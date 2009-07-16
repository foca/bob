module Bob
  module SCM
    class Git < Abstract
      def info(commit)
        format = %Q(---%n:author: %an <%ae>%n:message: >-%n  %s%n:committed_at: %ci%n)
        YAML.load(`cd #{directory_for(commit)} && git show -s --pretty=format:"#{format}" #{commit}`).tap { |info|
          info[:committed_at] = Time.parse(info[:committed_at])
        }
      end

      def head
        `git ls-remote --heads #{uri} #{branch} | cut -f1`.chomp
      end

      private

      def update_code(commit)
        unless File.directory?("#{cache_directory}/.git")
          run "git clone -n #{uri} #{cache_directory}", false
        end

        run "cd #{cache_directory} && git fetch origin", false
        run "cd #{cache_directory} && git checkout origin/#{branch}", false
      end

      def checkout(commit_id)
        unless File.directory?("#{directory_for(commit_id)}/.git")
          run "git clone -ns #{cache_directory} #{directory_for(commit_id)}", false
        end

        run "cd #{directory_for(commit_id)} &&  git fetch origin", false
        # First checkout the branch just in case the commit_id
        # turns out to be HEAD or other non-sha identifier
        run "cd #{directory_for(commit_id)} && git checkout origin/#{branch}", false
        run "cd #{directory_for(commit_id)} && git reset --hard #{commit_id}", false
      end

      def cache_directory
        File.join(Bob.directory, "cache", path).tap { |dir|
          FileUtils.mkdir_p(dir)
        }
      end

      def git(command)
        run "git #{command}"
      end
    end
  end
end
