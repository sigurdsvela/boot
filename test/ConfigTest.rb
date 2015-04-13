require 'test_helper.rb'
require 'tempfile'

include Boot::Lib::Core

describe Boot::Lib::Core::Config do
  describe '#initialize' do
    it 'throws if templates_path is not present' do
      file = Tempfile.new('foo')

      assert_raises(Boot::Lib::Core::InvalidConfigException) {
        file.write("{}")
        file.rewind
        Boot::Lib::Core::Config.new file.path
      }

      file.close
      file.unlink
    end

    it 'throws if templates_path does not exist' do
      file = Tempfile.new('foo')

      assert_raises(Boot::Lib::Core::InvalidConfigException) {
        file.write('{"templates_path":"not/a/directory"}')
        file.rewind
        Boot::Lib::Core::Config.new file.path
      }

      file.close
      file.unlink
    end

    it 'throws if templates_path is a file' do
      file = Tempfile.new('foo')
      notadir = Tempfile.new('notadir')

      assert_raises(Boot::Lib::Core::InvalidConfigException) {
        file.write('{"templates_path":"' + notadir.path + '"}')
        file.rewind
        Boot::Lib::Core::Config.new file.path
      }

      notadir.close
      notadir.unlink
      file.close
      file.unlink
    end

    it 'throws if array of files where 1 is not a valid directory' do
      Dir.mktmpdir { |dir|
        config_file = Tempfile.new('foo')
        config_file.write('{"template_path":["' + dir + '", "not/a/valid/path"]}')
        config_file.rewind
        assert_raises(Boot::Lib::Core::InvalidConfigException) {
          Boot::Lib::Core::Config.new config_file.path
        }
        config_file.close
        config_file.unlink
      }
    end
  end
end