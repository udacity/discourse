module Replacer

require 'yaml'

class Replace
    attr_reader :original, :with

    def initialize(original)
        @original = original
    end

    def withStr(with)
        @with = with
        self
    end
end

class DictHolder
    def initialize(dict)
        @dict = dict
    end

    def get_dict()
        @dict
    end

    def [](i)
        DictHolder.new(@dict[i])
    end

    def []=(i, value)
        raise NameError.new("Expected #{value.original} but was #{@dict[i]}") unless @dict[i] == value.original
        @dict[i] = value.with
    end

    def rename(from, to)
        @dict[to] = @dict[from]
        @dict.delete(from)
    end
end

def self.load_yaml(filename)
    DictHolder.new(YAML.load_file(filename))
end

def self.replace(original)
    Replace.new(original)
end

end
