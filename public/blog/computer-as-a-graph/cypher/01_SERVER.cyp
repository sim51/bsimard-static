:param fqdn => '@@FQDN@@';

MERGE (:Server {fqdn:$fqdn});