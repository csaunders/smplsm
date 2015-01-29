gem "minitest"
require "minitest/autorun"
require "smplsm"

module Smplsm
  class StateMachineTest < Minitest::Test
    attr_reader :item
    class Item; attr_accessor :state, :info; end

    class AnSM < StateMachine
      default :hello

      event :goodbye do
        transition :hello, to: :farewell do |obj|
          obj.info = 'hello -> farewell'
        end
      end

      event :hello_again do
        transition :farewell, to: :hello
      end
    end

    def setup
      @item = Item.new
      @machine = AnSM.new(@item, :state)
    end

    def test_creating_a_statemachine_without_a_to_transition_raises_an_error
      assert_raises StateMachine::StateDefinitionError do
        cls = Class.new(StateMachine) do
          event :a do
            transition :hello
          end
        end
      end
    end

    def test_getting_the_initial_state
      assert_equal :hello, @machine.default_state
    end

    def test_a_default_state
      assert_equal :hello, item.state
    end

    def test_a_transition
      assert_equal :hello, item.state
      item.goodbye
      assert_equal :farewell, item.state
    end

    def test_transitioning_evaluates_the_provided_block
      assert_nil item.info
      item.goodbye
      assert_equal 'hello -> farewell', item.info
    end

    def test_transitioning_does_not_raise_if_the_transition_block_is_nil
      item.state = :farewell
      item.hello_again
      assert_equal :hello, item.state
    end

    def test_an_invalid_transition
      assert_raises StateMachine::TransitionError do
        item.hello_again
      end
    end

    def test_initializing_a_statemachine_with_an_object_that_already_has_a_state
      item = Item.new
      item.state = :farewell
      AnSM.new(item, :state)
      assert_equal :farewell, item.state
    end

    def test_initializing_a_statemachine_whose_state_is_invalid
      item = Item.new
      item.state = :noodle
      assert_raises StateMachine::InvalidStateError do
        AnSM.new(item, :state)
      end
    end
  end
end
