module Graphiti::ActiveGraph
  module Query
    def filters
      @filters ||= begin
        {}.tap do |hash|
          (@params[:filter] || {}).each_pair do |name, value|
            name = name.to_sym

            if legacy_nested?(name)
              value.keys.each do |key|
                filter_name = key.to_sym
                filter_value = value[key]

                if @resource.get_attr!(filter_name, :filterable, request: true)
                  hash[filter_name] = filter_value
                end
              end
            elsif nested?(name)
              name = name.to_s.split(".").last.to_sym
              validate!(name, :filterable)
              hash[name] = value
            else
              hash[name] = value
            end
          end
        end
      end
    end

    def sorts
      return super unless (sort = params[:sort]) && sort.include?('.')

      @hash[:deep_sort] = sort_criteria(sort)
    end

    def self.parse_hash(hash)
      hash.map { |key, value| [key.to_s.split('.').map(&:to_sym), value] }.to_h
    end

    private

    def sort_criteria(sort)
      sort.split(',').map(&method(:sort_attr)).map(&self.class.method(:parse_hash))
    end

    def update_include_hash(authorized_include_param)
      @include_hash = authorized_include_param
      @sideloads = nil
    end
  end
end
