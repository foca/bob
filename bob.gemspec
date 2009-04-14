Gem::Specification.new do |s|
  s.name    = "bob"
  s.version = "0.1"
  s.date    = "2009-04-12"

  s.description = "Bob the Builder will build your code. Simple."
  s.summary     = "Bob builds!"
  s.homepage    = "http://integrityapp.com"

  s.authors = ["Nicolás Sanguinetti", "Simon Rozet"]
  s.email   = "info@integrityapp.com"

  s.require_paths     = ["lib"]
  s.rubyforge_project = "integrity"
  s.has_rdoc          = true
  s.rubygems_version  = "1.3.1"

  s.add_dependency "addressable"

  if s.respond_to?(:add_development_dependency)
    s.add_development_dependency "sr-mg"
    s.add_development_dependency "contest"
    s.add_development_dependency "redgreen"
    s.add_development_dependency "ruby-debug"
  end

  s.files = %w(
    .gitignore
    Rakefile
    README
    LICENSE
    lib/bob.rb
    lib/bob/builder.rb
    lib/bob/scm.rb
    lib/bob/scm/git.rb
    lib/bob/background_engines.rb
    lib/bob/background_engines/foreground.rb
    test/helper.rb
    test/helper/git_helper.rb
    test/unit/bob_test.rb
    test/unit/builder_test.rb
  )
end
