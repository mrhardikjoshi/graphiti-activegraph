module Graphiti::ActiveGraph::JsonapiExt
  class IncludeDirective < JSONAPI::IncludeDirective
    attr_accessor :length, :retain_rel_limit

    def initialize(include_args, options = {})
      include_hash = JSONAPI::IncludeDirective::Parser.parse_include_args(include_args)
      @retain_rel_limit = options.delete(:retain_rel_limit)
      @hash = formulate_hash(include_hash, options)
      @options = options
      @keys_cache = nil
      @to_hash_cache = nil
      @rel_meta_cache = {}
    end

    def keys
      @keys_cache ||= super.select(&method(:key?)).freeze
    end

    alias_method :get, :[]

    def key?(key)
      super && get(key).valid_length?
    end

    def [](key)
      super&.descend(key) || EMPTY_HASH
    end

    def descend(key)
      if length && length != ""
        dup.tap { |dup| dup.add_self_reference(key, length.to_i - 1) }
      else
        self
      end
    end

    def valid_length?
      length.nil? || length == "" || length.to_i.positive?
    end

    def to_hash
      return @to_hash_cache if @to_hash_cache

      result = @hash.each_with_object({}) do |(key, value), hash|
        next if value == self

        final_key = value.length ? :"#{key}*#{value.length}" : key
        hash[final_key] = value.to_hash
      end

      @to_hash_cache = result.freeze
    end

    def add_self_reference(key, length)
      @hash = @hash.merge(key => self)
      self.length = length
      clear_caches
    end

    private

    EMPTY_HASH = {}.freeze
    ASTERISK_PATTERN = /.+\*(\d*)\z/

    def formulate_hash(include_hash, options)
      options_with_rel_limit = options_with_retain_rel_limit(options)

      include_hash.each_with_object({}) do |(key, value), hash|
        rel_name, rel_length = extract_rel_meta(key)

        hash[rel_name] = self.class.new(value, options_with_rel_limit).tap do |directive|
          directive.add_self_reference(rel_name, rel_length) if key.to_s.match?(ASTERISK_PATTERN)
        end
      end
    end

    def extract_rel_meta(key)
      @rel_meta_cache[key] ||= Graphiti::ActiveGraph::Util::Transformers::RelationParam.new(key).split_rel_length(retain_rel_limit)
    end

    def options_with_retain_rel_limit(options)
      options.merge(retain_rel_limit:)
    end

    def clear_caches
      @keys_cache = nil
      @to_hash_cache = nil
    end
  end
end
