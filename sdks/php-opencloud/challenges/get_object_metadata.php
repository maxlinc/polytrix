<?php
require 'vendor/autoload.php';
use OpenCloud\Rackspace;

$region = getenv('RAX_REGION');
$endpoint = getenv('RAX_AUTH_URL') . '/v2.0/';
$credentials = array(
    'username' => getenv('RAX_USERNAME'),
    'apiKey' => getenv('RAX_API_KEY')
);
$directory = getenv('TEST_DIRECTORY');
$file = getenv('TEST_FILE');

$rackspace = new Rackspace($endpoint, $credentials);
$cloudFilesService = $rackspace->objectStoreService('cloudFiles', $region);
$container = $cloudFilesService->getContainer($directory);
$object = $container->getPartialObject($file);

?>
