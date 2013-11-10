<?php
require 'vendor/autoload.php';
use OpenCloud\Rackspace;

$endpoint = 'https://identity.api.rackspacecloud.com/v2.0/';
$credentials = array(
    'username' => getenv('RAX_USERNAME'),
    'apiKey' => getenv('RAX_API_KEY')
);

$rackspace = new Rackspace($endpoint, $credentials);
$rackspace->Authenticate();
echo('Authenticated')
?>
