require 'test_helper.rb'

include Boot::Lib::Core
include Slop

describe Boot::Lib::Core::SubCommand do
  before do
    @mockCommands = SubCommand.new "name", "description", Options.new do end
  end

  describe "#initialize" do
    it "set public fields correctly" do
      assert_equal "name", @mockCommands.name
      assert_equal "description", @mockCommands.description
    end
  end

end