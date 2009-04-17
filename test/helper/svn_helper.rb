require File.dirname(__FILE__) + "/abstract_scm_helper"

module TestHelper
  class SvnRepo < AbstractSCMRepo
    def self.pid_file
      "/tmp/bob-svnserve.pid"
    end

    def self.server_root
      "/tmp/bob-svnserver"
    end

    def self.start_server
      FileUtils.mkdir(server_root) unless File.directory?(server_root)

      `svnserve -d --pid-file #{pid_file} \
          --listen-host=0.0.0.0 --listen-port=1234 -r#{server_root} &>/dev/null`
    end

    def self.stop_server
      Process.kill("KILL", File.read(pid_file).chomp.to_i)
      File.delete(pid_file)
    end

    attr_reader :remote

    def initialize(name, base_dir=Bob.directory)
      super

      @path   = File.join(base_dir, "svn-#{@name}")
      @remote = File.join(SvnRepo.server_root, name.to_s)
    end

    def create
      create_remote

      system "svn checkout svn://0.0.0.0:1234/#{name} #{path} &>/dev/null"

      add_commit("First commit") do
        system "echo 'just a test repo' >> README"
        add    "README"
      end
    end

    def destroy
      super
      FileUtils.rm_rf(remote)
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

    protected
      def add(file)
        system "svn add #{file} &>/dev/null"
      end

      def commit(message)
        system %Q{svn commit -m "#{message}" &>/dev/null}
        system "svn up &>/dev/null"
      end

    private
      def create_remote
        system "svnadmin create #{remote} &>/dev/null"

        File.open(File.join(remote, "conf", "svnserve.conf"), "w") { |f|
          f.puts "[general]"
          f.puts "anon-access = write"
          f.puts "auth-access = write"
        }
      end
  end
end
