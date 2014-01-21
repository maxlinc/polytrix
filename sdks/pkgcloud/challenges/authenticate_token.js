var pkgcloud = require('pkgcloud');

// create our client with your rackspace credentials
var client = pkgcloud.providers.rackspace.compute.createClient({
  username: process.env.RAX_USERNAME,
  apiKey: process.env.RAX_API_KEY,
  authUrl: process.env.RAX_AUTH_URL
});
client.auth(function(err) {
  if (err) {
    console.log(err.message);
    process.exit(1);
  } else {
    console.log('Authenticated');
  }
});