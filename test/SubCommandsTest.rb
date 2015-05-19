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

  describe "#is_flag" do
    it "returns true for single dash flags" do
      assert Boot::Lib::Core::SubCommand.is_flag("-f")
    end

    it "returns true for double dash flags" do
      assert Boot::Lib::Core::SubCommand.is_flag("--f")
    end

    it "returns true for multi character double dash flags" do
      assert Boot::Lib::Core::SubCommand.is_flag("--fdsa")
    end

    it "returns false for multi character single dash flags" do
      assert !Boot::Lib::Core::SubCommand.is_flag("-fdsa")
    end

    it "returns false on missing dashes" do
      assert !Boot::Lib::Core::SubCommand.is_flag("fdsa")
    end
  end

end