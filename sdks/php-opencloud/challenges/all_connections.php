<?php
require 'vendor/autoload.php';
use OpenCloud\Rackspace;

$region = getenv('RAX_REGION');
$endpoint = getenv('RAX_AUTH_URL') . '/v2.0/';
$credentials = array(
    'username' => getenv('RAX_USERNAME'),
    'apiKey' => getenv('RAX_API_KEY')
);

$rackspace = new Rackspace($endpoint, $credentials);
$rackspace->Authenticate();

$compute = $rackspace->computeService('cloudServersOpenStack', $region);
$servers = $compute->serverList();
$networks = $compute->networkList();
echo("Servers: ".var_export($servers));
echo("Networks: ".var_export($networks));

$loadBalancerService = $rackspace->loadBalancerService('cloudLoadBalancers', $region);
$load_balancers = $loadBalancerService->loadBalancerList();
echo("Cloud Load Balancers: ".var_export($load_balancers));

$cloudFilesService = $rackspace->objectStoreService('cloudFiles', $region);
$containers = $cloudFilesService->listContainers();
echo("Cloud Files Containers: ".var_export($containers));

$databaseService = $rackspace->databaseService('cloudDatabases', $region);
$databases = $databaseService->instanceList();
echo("Cloud Databases: ".var_export($databases));

$dnsService = $rackspace->dnsService('cloudDNS', $region);
$domains = $dnsService->domainList();
// Can I get zones?
// echo("Cloud DNS: $zones")
echo('Cloud DNS: $domains');

$identityService = $rackspace->identityService();
$users = $identityService->getUsers();
echo("Cloud Identity Users: ".var_export($users));

$monitoringService = $rackspace->cloudMonitoringService('cloudMonitoring', 'ORD', 'publicURL');
$checkTypes = $monitoringService->getCheckTypes();
// Can I get the account info?
// echo("Cloud Monitoring Account: $account")
echo("Cloud Monitoring Check Types: ".var_export($checkTypes));

$blockStorageService = $rackspace->volumeService('cloudBlockStorage', 'DFW');
$volumes = $blockStorageService->volumeList(false);
echo("Cloud Block Storage Volumes: ".var_export($volumes));

# Cloud Backup?

$autoscaleService = $rackspace->autoscaleService();
$groups = $autoscaleService->groupList();
echo("Autoscale Scaling Groups: ".var_export($groups));

# Cloud Queues
$queuesService = $rackspace->queuesService('cloudQueues', $region);
$queues = $queuesService->listQueues();
echo("Cloud Queues: ".var_export($queues));

?>
