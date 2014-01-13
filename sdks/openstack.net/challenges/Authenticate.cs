using System;
using net.openstack.Providers.Rackspace;
using net.openstack.Core.Providers;
using net.openstack.Core.Exceptions.Response;
using net.openstack.Providers.Rackspace.Objects;

namespace openstack.net
{
	class Authenticate : Challenge
	{
		public int Run (string[] args)
		{
			IIdentityProvider identityProvider = new CloudIdentityProvider ();
			var userAccess = identityProvider.Authenticate (new RackspaceCloudIdentity {
				Username = Environment.GetEnvironmentVariable("RAX_USERNAME"),
				APIKey = Environment.GetEnvironmentVariable("RAX_API_KEY")
			});
			Console.WriteLine ("Authenticated!");
			return 0;
		}
	}
}
