:param fqdn => '@@FQDN@@';

MATCH (s:Server {fqdn:$fqdn})
MERGE (p:Process {pid:0, command:'init', fqdn:$fqdn})
MERGE (s)-[:HAS_PROCESS]->(p);

LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/processes.csv" AS row
WITH row ORDER BY row.PPID, row.PID  ASC
  MATCH (u:User {username:row.RUSER, fqdn:$fqdn})
  MERGE (pp:Process {pid:toInteger(row.PPID), fqdn:$fqdn})
  MERGE (p:Process {pid:toInteger(row.PID), fqdn:$fqdn})
  SET p.command = split(row.COMMAND, '/')[0]
  MERGE (pp)-[:HAS_PROCESS]->(p)
  MERGE (p)-[:OWNED_BY]->(u);