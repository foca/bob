require "fileutils"
require "yaml"
require "logger"
require "addressable/uri"

require "bob/builder"
require "bob/scm"
require "bob/scm/git"
require "bob/background_engines"

module Bob
  # Builds the specified +buildable+. This object must understand the following API:
  #
  # * buildable.repo_kind      
  #     Should return a Symbol with whatever kind of repository the buildable's code is 
  #     in (:git, :svn, etc).
  # * buildable.repo_uri
  #     Returns a string like "git://github.com/integrity/bob.git", pointing to the code
  #     repository.
  # * buildable.repo_branch
  #     What branch of the repository should we build? 
  # * buildable.build_script
  #     Returns a string containing the command to be run when "building".
  # * buildable.start_building(commit_id)
  #     `commit_id` is a String that contains whatever is appropriate for the repo type, 
  #     so it would be a SHA1 hash for git repos, or a numeric id for svn, etc. This is a
  #     callback so the buildable can determine how long it takes to build. It doesn't
  #     need to return anything.
  # * buildable.add_successful_build(commit_id, build_output)
  #     Called when the build finishes and is successful. It doesn't need to return 
  #     anything.
  # * buildable.add_failed_build(commit_id, build_output)
  #     Called when the build finishes and it failed. It doesn't need to return anything.
  #
  # The build process is to fetch the code from the repository (determined by
  # +buildable.repo_kind+ and +buildable.repo_uri+), then checkout the specified 
  # +commid_ids+, and finally run +buildable.build_script+ on each.
  #
  # If the script returns successfully then +buildable.add_successful_build+ will be 
  # called. If not, +buildable.add_failed_build+ is called instead. A successful build
  # is one where the build script returns a zero status code.
  def self.build(buildable, *commit_ids)
    raise ArgumentError, "at least one commit_id must be specified" if commit_ids.empty?
    commit_ids.each do |commit_id|
      Builder.new(buildable, commit_id).build
    end
  end

  # Dir where the code for the different buildables will be checked out. Make sure
  # the user running bob has writing permission on this directory.
  def self.base_dir
    @base_dir || "/tmp"
  end

  # What to log with (must implement ruby's Logger interface). Logs to STDOUT by
  # default.
  def self.logger
    @logger || Logger.new(STDOUT)
  end

  # What will you use to build in background. Must respond to #call and take a block
  # which will be run "in background". The default is to run in foreground.
  def self.background_engine
    @background_engine || BackgroundEngines::Foreground
  end

  class << self
    attr_writer :logger, :base_dir, :background_engine
  end
end
