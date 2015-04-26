require 'test_helper.rb'
require 'tempfile'

include Boot::Lib::Core

describe Boot::Lib::Core::Config do
  describe '#initialize' do
    it 'does not throw if template_path is present and valid' do
      Dir.mktmpdir { |dir|
        Boot::Lib::Core::Config.new({"templates_path"=>[dir]})
      }
    end

    it 'throws if templates_path does not exist' do
      assert_raises(Boot::Lib::Core::InvalidConfigException) {
        Boot::Lib::Core::Config.new({"templates_path"=>"not/a/directory"})
      }
    end

    it 'throws if templates_path is a file' do
      notadir = Tempfile.new('notadir')

      assert_raises(Boot::Lib::Core::InvalidConfigException) {
        Boot::Lib::Core::Config.new({"templates_path"=>notadir.path})
      }

      notadir.close
      notadir.unlink
    end

    it 'throws if array of files where 1 is not a valid directory' do
      Dir.mktmpdir { |dir|
        assert_raises(Boot::Lib::Core::InvalidConfigException) {
          Boot::Lib::Core::Config.new({"template_path"=>[dir, "not/a/valid/path"]})
        }
      }
    end
  end
end