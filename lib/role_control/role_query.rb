module RoleControl
  class RoleQuery
    def initialize(roles, public, resource_class)
      @roles, @public, @klass = roles, public, resource_class
    end

    def build(actor, target=nil, extra_tests=[])
      query_value, join_query = join_clause(actor, target)
      extra_tests << public_test if @public
      
      query = @klass.where(where_clause(!!join_query, extra_tests))
      query = query.joins(join_query) if join_query
      
      rebind(query, query_value)
    end

    private

    def rebind(query, query_values)
      return query unless query_values
      query_values.try(:reduce, query) { |q, b| q.bind(b) } 
    end

    def table
      @klass.arel_table
    end
    
    def roles_table
      @roles_table ||= Arel::Table.new(:roles_query)
    end

    def role_query(actor, target)
      target = target.nil? ? @klass : target
      q = actor.roles_query(target)
      query_value, arel = q.try(:bind_values), q.try(:arel).try(:as, 'roles_query')
      [query_value, arel]
    end

    def join_clause(actor, target)
      query_value, query = role_query(actor, target)
      query = table.create_join(query, join_on, Arel::Nodes::OuterJoin) if query
      [query_value, query]
    end
    
    def join_on
      table.create_on(roles_table[join_id].eq(table[:id]))
    end

    def join_id
      "#{ @klass.model_name.singular }_id".to_sym
    end

    def where_clause(include_roles, extra_tests)
      q = include_roles ? roles_test : extra_tests.pop 
      extra_tests.reduce(q) { |query, test| query.or(test) }
    end
    
    def public_test
      table[@roles].eq('{}')
    end
    
    def roles_test
      test = roles_table[:roles].not_eq(nil)
        .and(roles)

      Arel::Nodes::Grouping.new(test)
    end

    def roles
      if @roles.is_a?(Array)
        roles_table[:roles].overlap("{#{@roles.join(',')}}")
      else
        roles_table[:roles].overlap(table[@roles])
      end
    end
  end
end

