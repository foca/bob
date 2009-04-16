require "hpricot"

module SVNHelper
  def self.pid_file
    "/tmp/svnserve.pid"
  end

  def self.server_root
    "/tmp/svnserver"
  end

  def self.start_server
    FileUtils.mkdir(server_root) unless File.directory?(server_root)

    `svnserve -d --pid-file #{pid_file} \
        --listen-host=0.0.0.0 --listen-port=1234 -r#{server_root}`
  end

  def self.stop_server
    Process.kill("KILL", File.read(pid_file).chomp.to_i)
  end

  class Repo
    attr_reader :path, :name, :remote

    def initialize(name, base_dir=Bob.directory)
      @name   = name
      @path   = File.join(base_dir, @name.to_s)
      @remote = File.join(SVNHelper.server_root, name.to_s)
    end

    def create
      destroy
      create_remote

      system "svn checkout svn://0.0.0.0:1234/#{name} #{path}"

      add_commit("First commit") do
        system "echo 'just a test repo' >> README"
        system "svn add README"
      end
    end

    def destroy
      FileUtils.rm_rf(remote)
      FileUtils.rm_rf(path)
    end

    def commits
      Dir.chdir(path) do
        doc = Hpricot::XML(`svn log --xml`)

        (doc/:log/:logentry).inject([]) { |commits, commit|
          commits << { :identifier => commit["revision"],
            :message      => commit.at("msg").inner_html,
            :committed_at => Time.parse(commit.at("date").inner_html) }
        }
      end
    end

    def head
      commits.first[:identifier]
    end

    def add_commit(message, &action)
      Dir.chdir(@path) do
        yield action
        system %Q(svn commit -m "#{message}")
        system "svn up"
      end
    end

    def add_failing_commit
      add_commit "This commit will fail" do
        system %Q(echo '#{build_script(false)}' > test)
        system %Q(chmod +x test)
        system %Q(svn add test &>/dev/null)
      end
    end

    def add_successful_commit
      add_commit "This commit will work" do
        system "echo '#{build_script(true)}' > test"
        system "chmod +x test"
        system "svn add test"
      end
    end

    protected
      def build_script(successful=true)
        <<-script
#!/bin/sh
echo "Running tests..."
exit #{successful ? 0 : 1}
script
      end

    private
      def create_remote
        system "svnadmin create #{remote}"

        File.open(File.join(remote, "conf", "svnserve.conf"), "w") { |f|
          f.puts "[general]"
          f.puts "anon-access = write"
          f.puts "auth-access = write"
        }
      end
  end
end
