require "fileutils"
require "pathname"
require "yaml"
require "logger"
require "time"
require "ninja"
require "addressable/uri"

require "bob/buildable"
require "bob/builder"
require "bob/scm"

module Bob
  # Builds the specified <tt>buildable</tt>. This object must understand
  # the API described in the README.
  def self.build(buildable)
    Builder.new(buildable).build
  end

  # Directory where the code for the different buildables will be checked out.
  # Make sure the user running Bob is allowed to write to this directory.
  def self.directory
    Pathname(@directory || "/tmp")
  end

  # What to log with (must implement ruby's Logger interface). Logs to STDOUT
  # by default.
  def self.logger
    @logger || Logger.new(STDOUT)
  end

  class << self
    attr_writer :directory, :logger
  end
end
