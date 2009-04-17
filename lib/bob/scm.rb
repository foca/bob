require "bob/scm/abstract"

module Bob
  module SCM
    autoload :Git, "bob/scm/git"
    autoload :Svn, "bob/scm/svn"

    class CantRunCommand < RuntimeError; end

    # Factory to return appropriate SCM instances (according to repository kind)
    def self.new(kind, uri, branch)
      class_for(kind).new(uri, branch)
    end

    # A copy of Inflector.camelize, from ActiveSupport. It will convert
    # string to UpperCamelCase.
    def self.class_for(kind)
      class_name = kind.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      const_get(class_name)
    end
    private_class_method :class_for
  end
end
