# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opt/version'

Gem::Specification.new do |spec|
  spec.name          = 'opt'
  spec.version       = Opt::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = ['jg@altimos.de']
  spec.summary       = 'An option parsing library.'
  spec.description   = 'An option parsing library. Optional.'
  spec.homepage      = 'https://github.com/jgraichen/opt'
  spec.license       = 'LGPL-3.0+'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(bin|lib)/|.*LICENSE.*|.*README.*|.*CHANGELOG.*})
  end

  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'bundler', '~> 1.5'
end
