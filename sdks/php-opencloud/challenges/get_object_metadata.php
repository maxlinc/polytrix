<?php
require 'vendor/autoload.php';
use OpenCloud\Rackspace;

$region = getenv('RAX_REGION');
$endpoint = getenv('RAX_AUTH_URL') . '/v2.0/';
$credentials = array(
    'username' => getenv('RAX_USERNAME'),
    'apiKey' => getenv('RAX_API_KEY')
);

$rackspace = new Rackspace(RACKSPACE_US, $credentials);
$cloudFilesService = $rackspace->objectStoreService('cloudFiles', $region);
$container = $cloudFilesService->getContainer('asdf');
$object = $container->getPartialObject('asdf');
$object->getMetadata();
echo($object->getEtag());
echo("\n");
echo($object->getContent());
echo("\n");
$object->refresh();
echo($object->getContent());

?>
