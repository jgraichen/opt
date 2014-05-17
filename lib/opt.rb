require 'opt/version'

#
module Opt

  # Parse given arguments.
  #
  # Arguments must be given as an array of tokens
  # like `ARGV`.
  #
  def call(argv)

  end

  class << self
    def new(*args)
      Parser.new(*args)
    end
  end
end
