gem 'minitest'
require 'minitest/autorun'
require 'smplsm'

module Smplsm
  class StatefulTest < Minitest::Test
    class StatefulObject
      attr_reader :state

      include Stateful
      state_on :state, using: Class.new
    end

    def test_defining_a_class_that_is_stateful
      state_machine = Class.new
      stateful_class = Class.new do
        attr_reader :state

        include Stateful
        state_on :state, using: state_machine
      end

      assert_equal state_machine, stateful_class.sm_for(:state)
    end
  end
end
