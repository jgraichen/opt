require 'opt/version'

module Opt
  require 'opt/command'
  require 'opt/program'
  require 'opt/option'
  require 'opt/switch'

  def self.new
    Program.new.tap{|p| yield p if block_given? }
  end

  module Constants
    Inf      = 1.0 / 0
    Infinity = 1.0 / 0
    Identity = ->(x){ x }
  end

  include Constants
end

#   #
#   class Flag < Option
#     attr_reader :negated_long

#     REGEX = /^(?<word>[^-]+)-(?<rest>.+)/

#     def initialize(*)
#       super
#       @value        = options.fetch(:default, true)
#       @negated_long = Set.new

#       long.each do |code|
#         if (n = REGEX.match(code)) && (tl = self.class.translations[n[:word]])
#           @negated_long << "#{tl}#{tl.empty? ? '' : '-'}#{n[:rest]}"
#         elsif self.class.translations['']
#           tl = self.class.translations['']
#           @negated_long << "#{tl}#{tl.empty? ? '' : '-'}#{code}"
#         end
#       end
#     end

#     def accept?(argv)
#       if argv.first.type == :long && negated_long.include?(argv.first.value)
#         return true
#       else
#         super
#       end
#     end

#     def parse_argv(argv)
#       arg = argv.shift

#       case arg.type
#         when :long
#           if negated_long.include?(arg.value)
#             !value
#           else
#             value
#           end
#         when :short
#           arg.value.slice!(0, 1)
#           argv.unshift(arg) unless arg.value.empty?
#           value
#       end
#     end

#     class << self
#       def translations
#         {'with' => 'without', 'without' => 'with', '' => 'no', 'no' => '', 'not' => ''}
#       end
#     end
#   end
