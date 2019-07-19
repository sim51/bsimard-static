:param fqdn => '@@FQDN@@';

LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_interfaces.csv" AS row
WITH row,
  CASE  WHEN  row.type = 'inet' THEN split(row.ip, '/')[0] ELSE NULL END AS ipv4,
  CASE  WHEN  row.type = 'inet6' THEN split(row.ip, '/')[0] ELSE NULL END AS ipv6

  MATCH (s:Server {fqdn:$fqdn})

  MERGE (i:Interface { name: row.name, fqdn:$fqdn })
  SET i.ip = coalesce(ipv4, i.ip),
      i.ipv6 = coalesce(ipv6, i.ipv6)

  MERGE (s)-[:HAS_INTERFACE]->(i);