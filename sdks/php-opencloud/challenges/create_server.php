<?php
require('vendor/autoload.php');
use OpenCloud\Rackspace;

$endpoint = getenv('RAX_AUTH_URL') . '/v2.0/';
$credentials = array(
    'username' => getenv('RAX_USERNAME'),
    'apiKey'   => getenv('RAX_API_KEY')
);

$rackspace = new Rackspace($endpoint, $credentials);
$compute   = $rackspace->computeService('cloudServersOpenStack', getenv('RAX_REGION'));

$image_id  = getenv('SERVER1_IMAGE');
$flavor_id = getenv('SERVER1_FLAVOR');

// Create a server in DFW
$server    = $compute->Server();
// create it
print("Creating server...");
$server->create(array(
    'name' => 'php-opencloud server',
    // Using the image ID from ORD
    'image' => $compute->image($image_id),
    // And a flavor that's too small
    'flavor' => $compute->flavor($flavor_id)
));
print("requested, now waiting...\n");
print("ID=" . $server->id . "...\n");
$server->WaitFor("ACTIVE", 600, 'dot');
print("done\n");
exit(0);

function dot($server)
{
    printf("%s %3d%%\n", $server->status, $server->progress);
}

?>
