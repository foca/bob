require File.dirname(__FILE__) + "/abstract_scm_helper"

module TestHelper
  class GitRepo < AbstractSCMRepo
    def create
      FileUtils.mkdir_p @path

      Dir.chdir(@path) do
        system 'git init &>/dev/null'
        system 'git config user.name "John Doe"'
        system 'git config user.email "johndoe@example.org"'
        system 'echo "just a test repo" >> README'
        add    'README &>/dev/null'
        commit "First commit"
      end
    end

    def commits
      Dir.chdir(@path) do
        commits = `git log --pretty=oneline`.collect { |l| l.split(" ").first }
        commits.inject([]) do |commits, sha1|
          format  = "---%n:message: >-%n  %s%n:timestamp: %ci%n" +
            ":identifier: %H%n:author: %n :name: %an%n :email: %ae%n"
          commits << YAML.load(`git show -s --pretty=format:"#{format}" #{sha1}`)
        end
      end
    end

    def head
      Dir.chdir(@path) do
        `git log --pretty=format:%H | head -1`.chomp
      end
    end

    def short_head
      head[0..6]
    end

    protected
      def add(file)
        system "git add #{file}"
      end

      def commit(message)
        system %Q{git commit -m "#{message}" &>/dev/null}
      end
  end
end
