require 'test_helper.rb'

include Boot::Lib::Core

describe Template do
  
  describe "#structureFiles" do
    it "structures string" do
      assert_equal(
        Template.structureFiles("somefile"),
        [{"somefile"=>"somefile"}]
      )
    end

    it "structures array of string" do
      assert_equal(
        Template.structureFiles(
          [
            "somefile",
            "somefile2",
          ]
        ),
        [
          {"somefile"=>"somefile"},
          {"somefile2"=>"somefile2"},
        ]
      )
    end

    it "structures array of string and hashes" do
      assert_equal(
        Template.structureFiles(
          [
            "somefile",
            "somefile2",
            {"somefile3"=>"somefile3dest"},
          ]
        ),
        [
          {"somefile"=>"somefile"},
          {"somefile2"=>"somefile2"},
          {"somefile3"=>"somefile3dest"},
        ]
      )
    end

    it "structures array of string and multi hashes" do
      assert_equal(
        Template.structureFiles(
          [
            "somefile",
            "somefile2",
            {"somefile3"=>"somefile3dest"},
            {
              "somefile4"=>"somefile4dest",
              "somefile5"=>"somefile5dest"
            },
          ]
        ),
        [
          {"somefile"=>"somefile"},
          {"somefile2"=>"somefile2"},
          {"somefile3"=>"somefile3dest"},
          {"somefile4"=>"somefile4dest"},
          {"somefile5"=>"somefile5dest"},
        ]
      )
    end
  end

end
