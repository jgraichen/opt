# frozen_string_literal: true

require 'opt/version'

module Opt
  require 'opt/command'
  require 'opt/program'
  require 'opt/option'
  require 'opt/switch'

  def self.new
    Program.new.tap {|p| yield p if block_given? }
  end

  module Constants
    Inf      = 1.0 / 0
    Infinity = 1.0 / 0
    Identity = ->(x) { x }
  end

  include Constants
end
