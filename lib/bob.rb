require "fileutils"
require "yaml"
require "logger"
require "time"
require "addressable/uri"

require "bob/buildable"
require "bob/builder"
require "bob/scm"
require "bob/background_engines"
require "core_ext/object"

module Bob
  # Builds the specified <tt>buildable</tt>. This object must understand
  # the API described in the README.
  #
  # The second argument will take an array of commit_ids, which should be
  # strings with the relevant identifier (a SHA1 hash for git repositories,
  # a numerical revision for svn repositories, etc).
  #
  # You can pass :head as a commit identifier to build the latest commit
  # in the repo. Examples:
  #
  #     Bob.build(buildable, :head) # just build the head
  #     Bob.build(buildable, ["4", "3", "2"]) # build revision 4, 3, and 2
  #                                           # (in that order)
  #     Bob.build(buildable, [:head, "a30fb12"]) # build the HEAD and a30fb12
  #                                              # commits in this repo.
  def self.build(buildable, commit_ids)
    Array(commit_ids).each do |commit_id|
      Builder.new(buildable, commit_id).build
    end
  end

  # Directory where the code for the different buildables will be checked out.
  # Make sure the user running Bob is allowed to write to this directory.
  def self.directory
    @directory || "/tmp"
  end

  # What will you use to build in background. Must respond to <tt>call</tt> and
  # take a block which will be run "in background". The default is to run in 
  # foreground.
  def self.engine
    @engine || BackgroundEngines::Foreground
  end

  # What to log with (must implement ruby's Logger interface). Logs to STDOUT 
  # by default.
  def self.logger
    @logger || Logger.new(STDOUT)
  end

  class << self
    attr_writer :directory, :engine, :logger
  end
end
