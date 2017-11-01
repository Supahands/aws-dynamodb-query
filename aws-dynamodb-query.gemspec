
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/dynamodb/query/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws-dynamodb-query'
  spec.version       = Aws::Dynamodb::Query::VERSION
  spec.authors       = ['khaled83']
  spec.email         = ['khaled@supahands.com']

  spec.summary       = 'Executes low level API DynamoDB Query.'
  spec.description   = 'Executes low level API DynamoDB Query with less memory. Visit http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html for query details.'
  spec.homepage      = 'https://github.com/Supahands/aws-dynamodb-query.git'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
