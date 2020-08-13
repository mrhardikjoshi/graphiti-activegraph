module Graphiti::ActiveGraph
  module Scope
    def resolve_sideloads(parents)
      @query.sideloads.each_pair do |name, q|
        sideload = @resource.class.sideload(name)
        next if sideload.nil? || sideload.shared_remote?

        if sideload.assign_each_proc
          parents.each do |parent|
            children = sideload.assign_each_proc.call(parent) || []

            # currently there is no possible way to assign association on activegraph without triggering save
            # https://github.com/neo4jrb/activegraph/issues/1445
            # as a workaround we are using instance variable here to store and retrive associations
            # once above issue is fixed use that fix to assign the association here
            # and also remove 1) this code and 2) SerializerRelationship#data_proc
            parent.instance_variable_set("@graphiti_render_#{name}", children)
          end
        end
      end
    end

    # TO:DO this method shouldn't be here, move it to org-api
    def apply_scoping(scope, opts)
      super

      opts[:query_obj] = @query
      add_scoping(:include, ::JsonapiExt::Scoping::Include, opts) unless @resource.remote?

      @object
    end
  end
end
