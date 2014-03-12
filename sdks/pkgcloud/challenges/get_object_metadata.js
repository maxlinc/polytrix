var pkgcloud = require('pkgcloud');

// create our client with your rackspace credentials
var storageClient = pkgcloud.providers.rackspace.storage.createClient({
  username: process.env.RAX_USERNAME,
  apiKey: process.env.RAX_API_KEY,
  authUrl: process.env.RAX_AUTH_URL,
  region: process.env.RAX_REGION
});

storageClient.getFile(process.env.TEST_DIRECTORY, process.env.TEST_FILE, function (err, server) {
  if (err) {
    console.dir(err);
    return;
  }

  console.dir(server);
});
