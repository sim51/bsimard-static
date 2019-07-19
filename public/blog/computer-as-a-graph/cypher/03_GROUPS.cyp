:param fqdn => '@@FQDN@@';

LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/groups.csv" AS row FIELDTERMINATOR ':'
  MATCH (s:Server {fqdn:$fqdn})
  MERGE (g:Group { gid:toInteger(row.gid), fqdn:$fqdn })
  MERGE (s)-[:HAS_GROUP]->(g)
  SET g.name = row.name
  WITH row, g
  UNWIND split(row.users, ",") AS username
    MATCH (u:User { username:username, fqdn:$fqdn})
    MERGE (g)-[:HAS_USER]->(u);