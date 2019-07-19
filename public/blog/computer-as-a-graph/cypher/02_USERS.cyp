:param fqdn => '@@FQDN@@';

LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/users.csv" AS row FIELDTERMINATOR ':'
  MERGE (g:Group { gid:toInteger(row.gid), fqdn:$fqdn})
  MERGE(u:User {uid: toInteger(row.uid), fqdn:$fqdn})
  SET u.username = row.username,
      u.fullname = split(row.info, ',')[0],
      u.home_directory = row.home,
      u.shell = row.shell
  MERGE (g)-[:HAS_USER]->(u);