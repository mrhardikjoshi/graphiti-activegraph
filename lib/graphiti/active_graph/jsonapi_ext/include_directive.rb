module Graphiti::ActiveGraph::JsonapiExt
  class IncludeDirective < JSONAPI::IncludeDirective
    attr_accessor :length, :retain_rel_limit

    def initialize(include_args, options = {})
      include_hash = JSONAPI::IncludeDirective::Parser.parse_include_args(include_args)
      @retain_rel_limit = options.delete(:retain_rel_limit)
      @hash = formulate_hash(include_hash, options)
      @options = options
    end

    def keys
      super.select(&method(:key?))
    end

    alias get []

    def key?(key)
      super && get(key).valid_length?
    end

    def [](key)
      super&.descend(key) || {}
    end

    def descend(key)
      length && length != '' ? dup.tap { |dup| dup.add_self_reference(key, length.to_i - 1) } : self
    end

    def valid_length?
      length.nil? || length == '' || length.to_i.positive?
    end

    def to_hash
      @hash.each_with_object({}) do |(key, value), hash|
        key = "#{key}*#{value.length}".to_sym if value.length
        hash[key] = value.to_hash unless value == self
      end
    end

    def add_self_reference(key, length)
      @hash = @hash.merge(key => self)
      self.length = length
    end

    private

    def formulate_hash(include_hash, options)
      include_hash.each_with_object({}) do |(key, value), hash|
        rel_name, rel_length = extract_rel_meta(key)

        hash[rel_name] = self.class.new(value, options_with_retain_rel_limit(options)).tap do |directive|
          directive.add_self_reference(rel_name, rel_length) if key.to_s.match?(/.+\*(\d*)\z/)
        end
      end
    end

    def extract_rel_meta(key)
      Graphiti::ActiveGraph::Util::Transformers::RelationParam.new(key).split_rel_length(retain_rel_limit)
    end

    def options_with_retain_rel_limit(options)
      options.merge(retain_rel_limit:)
    end
  end
end
