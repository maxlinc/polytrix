using System;

namespace openstack.net
{
	public class RunChallenge
	{
		public static void Main (string[] args)
		{
			var challenge_class = Type.GetType("openstack.net." + args[0]);
			var challenge_object = Activator.CreateInstance(challenge_class) as Challenge;
			challenge_object.Run(args);
		}
	}
}

