gem "minitest"
require "minitest/autorun"
require "smplsm"

module Smplsm
  class StateMachineTest < Minitest::Test
    attr_reader :item
    class Item; attr_accessor :state; end

    class AnSM < StateMachine
      default :hello

      event :goodbye do
        transition :hello, to: :farewell
      end

      event :hello_again do
        transition :farewell, to: :hello
      end
    end

    def setup
      @item = Item.new
      @machine = AnSM.new(@item, :state)
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

    def test_an_invalid_transition
      assert_raises StateMachine::TransitionError do
        item.hello_again
      end
    end
  end
end
