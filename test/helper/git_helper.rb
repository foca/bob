module TestHelper
  class GitRepo
    attr_reader :path, :name

    def initialize(name, base_dir=Bob.directory)
      @name = name
      @path = File.join(base_dir, @name.to_s)
      create
    end

    def path
      File.join(@path, ".git")
    end

    def create
      destroy
      FileUtils.mkdir_p @path

      Dir.chdir(@path) do
        system 'git init &>/dev/null'
        system 'git config user.name "John Doe"'
        system 'git config user.email "johndoe@example.org"'
        system 'echo "just a test repo" >> README'
        system 'git add README &>/dev/null'
        system 'git commit -m "First commit" &>/dev/null'
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

    def add_commit(message, &action)
      Dir.chdir(@path) do
        yield action
        system %Q(git commit -m "#{message}" &>/dev/null)
      end
    end

    def add_failing_commit
      add_commit "This commit will fail" do
        system %Q(echo '#{build_script(false)}' > test)
        system %Q(chmod +x test)
        system %Q(git add test &>/dev/null)
      end
    end

    def add_successful_commit
      add_commit "This commit will work" do
        system %Q(echo '#{build_script(true)}' > test)
        system %Q(chmod +x test)
        system %Q(git add test &>/dev/null)
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

    def destroy
      FileUtils.rm_rf @path if File.directory?(@path)
    end

    protected

      def build_script(successful=true)
        <<-script
#!/bin/sh
echo "Running tests..."
exit #{successful ? 0 : 1}
script
      end
  end
end
