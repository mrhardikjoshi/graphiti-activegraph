def set_default_driver
  server_url = ENV['NEO4J_URL'] || 'neo4j://localhost:7689'
  user = ENV['NEO4J_USER'] || 'neo4j'
  pass = ENV['NEO4J_PASS'] || 'password'

  ActiveGraph::Base.driver =
    Neo4j::Driver::GraphDatabase.driver(server_url, Neo4j::Driver::AuthTokens.basic(user, pass))
end
