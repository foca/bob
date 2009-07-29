module Bob
  module SCM
    class Git < Abstract
      protected

      def info(commit)
        format = %Q(---%nidentifier: %H%nauthor: %an <%ae>%nmessage: >-%n  %s%ncommitted_at: %ci%n)
        YAML.load(`cd #{directory_for(commit)} && git show -s --pretty=format:"#{format}" #{commit}`).tap { |info|
          info["committed_at"] = Time.parse(info["committed_at"])
        }
      end

      def head
        `git ls-remote --heads #{uri} #{branch} | cut -f1`.chomp
      end

      private

      def update_code(commit)
        run "git clone #{uri} #{directory_for(commit)}" unless cloned?(commit)
      end

      def checkout(commit)
        run "git fetch origin", directory_for(commit)
        run "git checkout origin/#{branch}", directory_for(commit)
        run "git reset --hard #{commit}", directory_for(commit)
      end

      def cloned?(commit)
        directory_for(commit).join(".git").directory?
      end
    end
  end
end
