:param fqdn => '@@FQDN@@';

LOAD CSV WITH HEADERS FROM "file:///" + $fqdn + "/packages.csv" AS row FIELDTERMINATOR '\t'
  MATCH (s:Server {fqdn:$fqdn})

  MERGE (section:PackageSection {name:coalesce(row.section, 'None') })
  MERGE (package:Package {name:row.package})
  SET package.url = row.homepage
  MERGE (section)-[:HAS_PACKAGE]->(package)

  MERGE (pv:PackageVersion { version:row.version, architecture:row.architecture, name:row.package})
  MERGE (package)-[:HAS_VERSION]->(pv)

  MERGE (s)-[:HAS_PACKAGE]->(pv)

  FOREACH( dep IN split(row.dependencies, ',') |
    MERGE (depNode:Package {name:split(dep, '(')[0] })
    MERGE (pv)-[r:HAS_DEPENDENCY]->(depNode)
    SET r.constraint = replace(split(dep, '(' )[1], ')','')
  );