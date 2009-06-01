Gem::Specification.new do |s|
  s.name    = "bob-the-builder"
  s.version = "0.1.1"
  s.date    = "2009-05-08"

  s.description = "Bob the Builder will build your code. Simple."
  s.summary     = "Bob builds!"
  s.homepage    = "http://integrityapp.com"

  s.authors = ["Nicolás Sanguinetti", "Simon Rozet"]
  s.email   = "info@integrityapp.com"

  s.require_paths     = ["lib"]
  s.rubyforge_project = "bob-the-builder"
  s.has_rdoc          = true
  s.rubygems_version  = "1.3.1"

  s.add_dependency "addressable"

  if s.respond_to?(:add_development_dependency)
    s.add_development_dependency "sr-mg"
    s.add_development_dependency "sr-bob-test"
    s.add_development_dependency "contest"
    s.add_development_dependency "redgreen"
    s.add_development_dependency "ruby-debug"
  end

  s.files = %w[
.gitignore
LICENSE
README.rdoc
Rakefile
bob-the-builder.gemspec
lib/bob.rb
lib/bob/background_engines.rb
lib/bob/background_engines/foreground.rb
lib/bob/background_engines/threaded.rb
lib/bob/builder.rb
lib/bob/buildable.rb
lib/bob/scm.rb
lib/bob/scm/abstract.rb
lib/bob/scm/git.rb
lib/bob/scm/svn.rb
lib/core_ext/object.rb
test/background_engine/threaded_test.rb
test/bob_test.rb
test/helper.rb
test/helper/abstract_scm_helper.rb
test/helper/buildable_stub.rb
test/helper/git_helper.rb
test/helper/svn_helper.rb
test/scm/git_test.rb
test/scm/svn_test.rb
]
end
