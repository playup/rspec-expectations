require 'json'

module RSpec
  module Matchers
    class BeJsonMatching < BeMatching
      def matches?(actual)
        super(JSON.parse(actual))
      end
    end

    def be_json_matching(expected, opts={})
      Matchers::BeJsonMatching.new(expected, opts)
    end
  end
end
