var pkgcloud = require('pkgcloud');

// create our client with your rackspace credentials
var client = pkgcloud.providers.rackspace.compute.createClient({
  username: process.env.RAX_USERNAME,
  apiKey: process.env.RAX_API_KEY,
  authUrl: process.env.RAX_AUTH_URL
});
client.getImages(function(images) {
    console.log('Authenticated');
});
