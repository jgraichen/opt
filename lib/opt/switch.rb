# frozen_string_literal: true

require 'set'

module Opt
  #
  # A single command line switch.
  #
  class Switch
    class << self
      #
      # Parse an object or string into a Set of switches.
      #
      # @example
      #   Opt::Switch.parse '-h, --help'
      #   #=> Set{<Switch: -h>, <Switch: --help>}
      #
      def parse(object)
        if object.is_a?(self)
          object
        else
          if object.respond_to?(:to_str)
            parse_str object.to_str
          else
            parse_str object.to_s
          end
        end
      end

      # Create new command line switch.
      #
      # If a Switch object is given it will be returned instead.
      #
      # @see #initialize
      #
      def new(object)
        if object.is_a?(self)
          object
        else
          super object
        end
      end

      private

      def parse_str(str)
        Set.new str.split(/\s*,\s*/).map {|s| new s }
      end
    end

    # Switch name.
    #
    attr_reader :name

    # Regular expression matching an accepted command line switch
    REGEXP = /\A(?<dash>--?)(?<name>[[:word:]]+([[[:word:]]-]*[[:word:]])?)\z/

    def initialize(str)
      match = REGEXP.match(str)
      raise "Invalid command line switch: #{str.inspect}" unless match

      @name = match[:name].freeze

      @short = case match[:dash].to_s.size
                 when 0
                   name.size == 1
                 when 1
                   true
                 else
                   false
               end
    end

    def short?
      @short
    end

    def long?
      !short?
    end

    def eql?(object)
      if object.is_a?(self.class)
        name == object.name
      else
        super
      end
    end

    def hash
      name.hash
    end

    def match?(argv)
      case (arg = argv.first).type
        when :long
          long? && arg.value.split('=')[0] == name
        when :short
          short? && arg.value[0] == name[0]
        else
          false
      end
    end

    def match!(argv)
      return false unless match?(argv)

      if short? && argv.first.value.size > 1
        argv.first.value.slice!(0, 1)
      else
        arg = argv.shift

        if arg.value.include?('=')
          argv.unshift Command::Token.new(:text, arg.value.split('=', 2)[1])
        end
      end

      true
    end
  end
end
