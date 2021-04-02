require_relative 'lib/njpw/version'

Gem::Specification.new do |spec|
  spec.name          = "njpw"
  spec.version       = Njpw::VERSION
  spec.authors       = ["Takahiro Kanno"]
  spec.email         = ["kerochelo@gmail.com"]

  spec.summary       = "Easily generate njpw data"
  spec.description   = "njpw, a port of Data is used to easily generate njpw data: names, units, etc."
  spec.homepage      = "https://github.com/kerochelo/njpw.git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kerochelo/njpw.git"
  spec.metadata["changelog_uri"] = "https://github.com/kerochelo/njpw/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "1.12.0"
end
