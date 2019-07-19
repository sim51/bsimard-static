:param fqdn => '@@FQDN@@';

// listen port on IPv4  and not on all interfaces
LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_connections.csv" AS row
  WITH
    row,
    toInteger(last(split(row.local, ':'))) AS local_port,
    toInteger(split(row.pid,'/')[0]) AS pid
  WHERE
    row.state = 'LISTEN' AND
    size(split(row.local, '.')) > 1 AND // only IPv4
    (NOT row.local = '::' AND NOT row.local = '0.0.0.0') // Not for all interfaces
  WITH
    row,
    replace(row.local, ':'+ local_port, '') AS local_ip,
    local_port,
    pid,
    CASE WHEN pid IS NULL THEN [] ELSE [1] END AS ifPid

    MATCH (i:Interface { ip: local_ip, fqdn:$fqdn })
    MERGE (p:Port { number: local_port, ip:local_ip })
    MERGE (i)-[:USES_PORT]->(p)
    SET p.ip = i.ip,
        p.ipv6 = i.ipv6

    FOREACH( x IN ifPid |
      MERGE (process:Process {pid:pid, fqdn:$fqdn})
      MERGE (process)-[:LISTEN_ON]->(p)
    );

// listen port on IPv6 and not on all interfaces
LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_connections.csv" AS row
  WITH
    row,
    toInteger(last(split(row.local, ':'))) AS local_port,
    toInteger(split(row.pid,'/')[0]) AS pid
  WHERE
    row.state = 'LISTEN' AND
    size(split(row.local, '.')) = 0 AND // only IPv6
    (NOT row.local STARTS WITH '::' AND NOT row.local STARTS WITH '0.0.0.0') // Not for all interfaces
  WITH
    row,
    replace(row.local, ':'+ local_port, '') AS local_ip,
    local_port,
    pid,
    CASE WHEN pid IS NULL THEN [] ELSE [1] END AS ifPid

    MATCH (i:Interface { ipv6: local_ip, fqdn:$fqdn })
    MERGE (p:Port { number: local_port, ipv6:local_ip})
    MERGE (i)-[:USES_PORT]->(p)
    SET p.ip = i.ip,
        p.ipv6 = i.ipv6

    FOREACH( x IN ifPid |
      MERGE (process:Process {pid:pid, fqdn:$fqdn})
      MERGE (process)-[:LISTEN_ON]->(p)
    );

// listen port on all ipv4 interfaces
LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_connections.csv" AS row
  WITH
    row,
    toInteger(last(split(row.local, ':'))) AS local_port,
    toInteger(split(row.pid,'/')[0]) AS pid
  WHERE
    row.state = 'LISTEN' AND
    ( row.local STARTS WITH '0.0.0.0') //  all interfaces
  WITH
    row,
    local_port,
    pid,
    CASE WHEN pid IS NULL THEN [] ELSE [1] END AS ifPid

    MATCH (i:Interface {fqdn:$fqdn })
    MERGE (p:Port { number: local_port, ip:i.ip})
    SET p.ipv6 = i.ipv6
    MERGE (i)-[:USES_PORT]->(p)

    FOREACH( x IN ifPid |
      MERGE (process:Process {pid:pid, fqdn:$fqdn})
      MERGE (process)-[:LISTEN_ON]->(p)
    );

// listen port on all ipv6 interfaces
LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_connections.csv" AS row
  WITH
    row,
    toInteger(last(split(row.local, ':'))) AS local_port,
    toInteger(split(row.pid,'/')[0]) AS pid
  WHERE
    row.state = 'LISTEN' AND
    ( row.local STARTS WITH ':::*') //  all interfaces
  WITH
    row,
    local_port,
    pid,
    CASE WHEN pid IS NULL THEN [] ELSE [1] END AS ifPid

    MATCH (i:Interface {fqdn:$fqdn })
    MERGE (p:Port { number: local_port, ipv6:i.ipv6})
    SET p.ip = i.ip
    MERGE (i)-[:USES_PORT]->(p)

    FOREACH( x IN ifPid |
      MERGE (process:Process {pid:pid, fqdn:$fqdn})
      MERGE (process)-[:LISTEN_ON]->(p)
    );

// IPv4 connections
LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_connections.csv" AS row
  WITH
    row,
    toInteger(last(split(row.local, ':'))) AS local_port,
    toInteger(last(split(row.remote, ':'))) AS remote_port,
    toInteger(split(row.pid,'/')[0]) AS pid
  WHERE
    row.state = 'ESTABLISHED' AND
    size(split(row.local, '.')) > 1 // only ipv4
  WITH
    row,
    replace(row.local, ':'+ local_port, '') AS local_ip,
    local_port,
    replace(row.remote, ':'+ remote_port, '') AS remote_ip,
    remote_port,
    pid,
    CASE WHEN pid IS NULL THEN [] ELSE [1] END AS ifPid

    MATCH (s:Server {fqdn:$fqdn})

    MATCH (iLocal:Interface {ip: local_ip, fqdn:$fqdn })
    MERGE (iLocal)-[:USES_PORT]->(pLocal:Port { number: local_port})
    SET pLocal.ip = iLocal.ip,
        pLocal.ipv6 = iLocal.ipv6

    MERGE (iLocal)-[:USES_PORT]->(pLocal)

    MERGE (pRemote:Port { number: remote_port, ip:remote_ip })

    MERGE (con:Connection { fqdn:$fqdn, pid:coalesce(pid,'-'), local:row.local, remote:row.remote})
    MERGE (con)-[:SOURCE]->(pLocal)
    MERGE (con)-[:TARGET]->(pRemote)

    FOREACH( x IN ifPid |
      MERGE (process:Process {pid:pid, fqdn:$fqdn})
      MERGE (process)-[:HAS_CONNECTION]->(con)
    );

// IPv6 connections
LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/network_connections.csv" AS row
  WITH
    row,
    toInteger(last(split(row.local, ':'))) AS local_port,
    toInteger(last(split(row.remote, ':'))) AS remote_port,
    toInteger(split(row.pid,'/')[0]) AS pid
  WHERE
    row.state = 'ESTABLISHED' AND
    size(split(row.local, '.')) = 0
  WITH
    row,
    replace(row.local, ':'+ local_port, '') AS local_ip,
    local_port,
    replace(row.remote, ':'+ remote_port, '') AS remote_ip,
    remote_port,
    pid,
    CASE WHEN pid IS NULL THEN [] ELSE [1] END AS ifPid

    MATCH (s:Server {fqdn:$fqdn})

    MATCH (iLocal:Interface {ipv6: local_ip, fqdn:$fqdn })
    MERGE (iLocal)-[:USES_PORT]->(pLocal:Port { number: local_port})
    SET pLocal.ip = iLocal.ip,
        pLocal.ipv6 = iLocal.ipv6

    MERGE (pRemote:Port { number: remote_port, ip:remote_ip })

    MERGE (con:Connection { fqdn:$fqdn, pid:coalesce(pid,'-'), local:row.local, remote:row.remote})
    MERGE (con)-[:SOURCE]->(pLocal)
    MERGE (con)-[:TARGET]->(pRemote)

    FOREACH( x IN ifPid |
      MERGE (process:Process {pid:pid, fqdn:$fqdn})
      MERGE (process)-[:HAS_CONNECTION]->(con)
    );