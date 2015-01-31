gem 'minitest'
require 'minitest/autorun'
require 'smplsm'

module Smplsm
  class StatefulTest < Minitest::Test
    class SM < StateMachine
      default :hello
    end

    class StatefulObject
      attr_accessor :state

      include Stateful
      state_on :state, using: SM
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

    def test_using_state_on_with_nil_raises_an_error
      assert_raises Stateful::InvalidStateMachineError do
        Class.new do
          attr_reader :state
          include Stateful
          state_on :state
        end
      end
    end

    def test_using_state_on_the_same_field_raises_an_error
      assert_raises Stateful::StateRedefinitionError do
        Class.new do
          attr_reader :state
          include Stateful
          state_on :state, using: Class.new
          state_on :state, using: Class.new
        end
      end
    end

    def test_initializing_a_stateful_object_initializes_the_machines_and_sets_the_default
      obj = StatefulObject.new
      assert_equal :hello, obj.state
    end
  end
end
