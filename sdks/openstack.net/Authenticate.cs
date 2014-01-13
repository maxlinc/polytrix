using System;
using net.openstack.Providers.Rackspace;
using net.openstack.Core.Providers;
using net.openstack.Core.Exceptions.Response;
using net.openstack.Providers.Rackspace.Objects;

namespace openstack.net
{
	class MainClass
	{
		public static void Main (string[] args)
		{
			IIdentityProvider identityProvider = new CloudIdentityProvider ();
			var userAccess = identityProvider.Authenticate (new RackspaceCloudIdentity {
				Username = args [0], 
				APIKey = args [1]
			});
			Console.WriteLine ("Authenticated!");
		}
	}
}
