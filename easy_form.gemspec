# frozen_string_literal: true

require_relative "lib/easy_form/version"

Gem::Specification.new do |spec|
  spec.name = "easy_form"
  spec.version = EasyForm::VERSION
  spec.authors = ["Andrii Baran"]
  spec.email = ["andriy.baran.v@gmail.com"]

  spec.summary = "Easy form builder for Rails"
  spec.description = "Easy form builder for Rails"
  spec.homepage = "https://github.com/andriy-baran/easy_form"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andriy-baran/easy_form"
  spec.metadata["changelog_uri"] = "https://github.com/andriy-baran/easy_form/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "easy_params", "~> 0.6.2"
  spec.add_dependency "phlex", ">= 2"
  spec.add_dependency "railties", ">= 6.0.0"
end
