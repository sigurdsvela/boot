require 'test_helper.rb'

include Boot::Lib::Core

describe Template do

  # Integration tests
  describe "#initialize" do
    test_dir = File.dirname(File.expand_path(__FILE__))
    template_examples = test_dir + "/template-examples"

    it "it does not throw on perfect template" do
      Template.new template_examples + "/perfect"
    end

    it "does not pass json validation on invalid templates" do
      # The json schema should validate to false on these
      # tempaltes
      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/missing-description"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/missing-name"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/invalid-option"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/missing-flag-description"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/missing-option-description"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/missing-symbol-description"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/static-folders-invalid-type"
      }
    end

    it "throws on invalid static folders" do
      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/static-folder-invalid"
      }

      assert_raises(InvalidTemplateException) {
        Template.new template_examples + "/static-folders-invalid"
      }
    end
  end


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
