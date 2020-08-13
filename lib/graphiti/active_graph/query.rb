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

    def update_include_hash(authorized_include_param)
      @include_hash = authorized_include_param
      @sideloads = nil
    end
  end
end
