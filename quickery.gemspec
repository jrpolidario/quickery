
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quickery/version'

Gem::Specification.new do |spec|
  spec.name          = 'quickery'
  spec.version       = Quickery::VERSION
  spec.authors       = ['Jules Roman Polidario']
  spec.email         = ['jrpolidario@gmail.com']

  spec.summary       = 'Database Anti-normalization pattern implementing Law of Demeter by mapping associated record attributes as own attributes (one-way read-only), and therefore improves query speeds at the cost of slower writes.'
  spec.description   = 'Implements Law of Demeter by mapping associated record attributes as own attributes (one-way read-only). Consequently, speeds up SQL queries by removing joins queries between intermediary models, at the cost of slower writes. This is an anti-normalization pattern in favour of actual data-redundancy and faster queries. Use this only as necessary.'
  spec.homepage      = 'https://github.com/jrpolidario/quickery'
  spec.license       = 'MIT'
  
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'byebug', '~> 9.0'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.7.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.7.2'
  spec.add_development_dependency 'sqlite3', '~> 1.3.13'
  spec.add_development_dependency 'database_cleaner', '~> 1.7.0'
  spec.add_development_dependency 'faker', '~> 1.9.1'
  spec.add_development_dependency 'combustion', '~> 0.9.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'appraisal', '~> 2.2.0'
end
