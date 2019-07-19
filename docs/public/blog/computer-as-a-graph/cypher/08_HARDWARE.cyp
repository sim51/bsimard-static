:param fqdn => '@@FQDN@@';

// Define the custom recursive procedure
CALL apoc.custom.asProcedure(
	'hardware',
  "
  MATCH (p) WHERE id(p)=$parent

  MERGE (vendor:Vendor { name:coalesce($item.vendor, 'unknown')})
  MERGE (product:Product { name:coalesce($item.product, 'unknown'), vendor:coalesce($item.vendor, 'unknown')})
    ON CREATE SET product.description = $item.description
  MERGE (vendor)-[:HAS_PRODUCT]->(product)

  MERGE (hardware:Hardware {id:$item.id + '-' + coalesce($item.physid, '') + '-' + coalesce($item.handle, '') , fqdn:$fqdn})
  SET hardware +=apoc.map.removeKeys($item,['id', 'children', 'capabilities', 'configuration', 'vendor', 'product'])
  MERGE (p)-[:HAS_HARDWARE]->(hardware)
  MERGE (hardware)-[:TYPE_OF]->(product)

  WITH  hardware
  UNWIND coalesce($item.children, []) AS newItem
    CALL custom.hardware($fqdn, id(hardware), newItem) YIELD row
    RETURN row
  ",
  "write",
  [["row","MAP"]],
  [
    ['fqdn','STRING'],
    ['parent','LONG'],
    ['item','MAP']
  ]
);

// Calling the procedure with the data
CALL apoc.load.json("file:///" + $fqdn + "/hardware.json") YIELD value WITH value
 MATCH (s:Server {fqdn:$fqdn})
 CALL custom.hardware($fqdn, id(s), value) YIELD row
 RETURN count(*);

// Add label from the class property
MATCH (n:Hardware)
CALL apoc.create.addLabels( id(n), [ n.class ] ) YIELD node
REMOVE node.class
RETURN count(*)
;
