require 'test_helper.rb'
require 'json-schema'
require 'JSON'

include Boot::Lib::Core
include Slop

templateSchemaFile = File.open(File.dirname((File.dirname(File.expand_path(__FILE__)))) + "/lib/template.json-schema", "rb")
templateSchema = JSON.parse(templateSchemaFile.read)

jsonSchemaFile = File.open((File.dirname(File.expand_path(__FILE__))) + "/json-schema.json-schema", "rb")
jsonSchemaSchema = JSON.parse(jsonSchemaFile.read)

describe "template json schema file" do

  # template.json-schema is a valid schema
  it "is a valid json-schema" do
    errors = JSON::Validator.fully_validate(jsonSchemaSchema, templateSchema, :validate_schema=>true)
    assert(errors.length==0, errors * "\n")
  end

  it "passes basic template.json file" do
    errors = JSON::Validator.fully_validate(templateSchema, {
      "name"        => "TemplateName",
      "description" => "Description Of This Template",
      "static"      => "static/files",
      "options"     => {}
    })
    assert(errors.length==0, errors * "\n")
  end

  it "passes basic template.json file with options" do
    errors = JSON::Validator.fully_validate(templateSchema, {
      "name"        => "TemplateName",
      "description" => "Description Of This Template",
      "static"      => "static/files",
      "options"     => {
        "--option" => {
          "values" => {
            "value"  => "somefile",
            "value2" => ["somefiles"],
            "value3" => {"src/files" => "dest/path"}
          },
          "description" => "choose files"
        },
        "--flag" => {
          "files" => ["somefile", {"some"=>"qualified", "files"=>"dest"}],
          "description" => "description"
        }
      }
    })
    assert(errors.length==0, errors * "\n")
  end

  it "passes without static or options" do
    errors = JSON::Validator.fully_validate(templateSchema, {
      "name"        => "TemplateName",
      "description" => "Description Of This Template"
    })
    assert(errors.length==0, errors * "\n")
  end

  it "failes on missing name property" do
    assert_raises(JSON::Schema::ValidationError) {
      JSON::Validator.validate!(templateSchema, {
        "description" => "Description Of This Template",
        "static"      => "static/files",
        "options"     => {}
      })
    }
  end

  it "failes on missing description" do
    assert_raises(JSON::Schema::ValidationError) {
      JSON::Validator.validate!(templateSchema, {
        "name"        => "TemplateName",
        "static"      => "static/files",
        "options"     => {}
      })
    }
  end

  it "failes on singe dash with multiple character option" do
    assert_raises(JSON::Schema::ValidationError) {
      JSON::Validator.validate!(templateSchema, {
        "name"        => "TemplateName",
        "description" => "Description Of This Template",
        "options"     => {
          "-multiple" => {
            "files" => "thefile",
            "description" => "Adds thefile"
          }
        }
      })
    }
  end

  it "failes on extra options in root, or in the options" do
    base = {
      "name"        => "TemplateName",
      "description" => "Description Of This Template",
      "options"     => {
        "--flag" => {
          "files" => "thefile",
          "description" => "Adds thefile"
        },
        "--argument" => {
          "values" => {
            "value"  => "somefile",
            "value2" => ["somefiles"],
            "value3" => {"src/files" => "dest/path"}
          },
          "description" => "Adds thefile"
        }
      }
    }
    _base = base

    _base["extra"] = "option"
    assert_raises(JSON::Schema::ValidationError) {
      JSON::Validator.validate!(templateSchema, _base)
    }
    _base = base

    _base["options"]["--argument"]["extra"] = "option"
    assert_raises(JSON::Schema::ValidationError) {
      JSON::Validator.validate!(templateSchema, _base)
    }
    _base = base

    _base["options"]["--flag"]["extra"] = "option"
    assert_raises(JSON::Schema::ValidationError) {
      JSON::Validator.validate!(templateSchema, _base)
    }
    _base = base
  end
end