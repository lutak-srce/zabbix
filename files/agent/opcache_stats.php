<?php
$status = opcache_get_status();
echo "opcache_hit_rate " . $status[opcache_statistics][opcache_hit_rate] . "\n" . "used_memory " . $status[memory_usage][used_memory] . "\n";
?>
