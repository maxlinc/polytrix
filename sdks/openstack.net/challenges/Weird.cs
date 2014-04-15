using System;
using System.IO;
using System.Text;
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using net.openstack.Core.Domain;
using net.openstack.Core.Providers;
using net.openstack.Providers.Rackspace;
using net.openstack.Providers.Rackspace.Objects;
using HttpMethod = JSIStudios.SimpleRESTServices.Client.HttpMethod;

namespace openstack.net
{
  class Weird : Challenge
  {
    public int Run (string[] args)
    {
      var auth_url = new Uri(Environment.GetEnvironmentVariable ("RAX_AUTH_URL"));
      Console.WriteLine ("Connecting to " + auth_url);
      CloudIdentity identity = new RackspaceCloudIdentity {
        Username = Environment.GetEnvironmentVariable("RAX_USERNAME"),
        APIKey = Environment.GetEnvironmentVariable("RAX_API_KEY")
      };
      // IIdentityProvider identityProvider = new CloudIdentityProvider (identity, auth_url);
      IIdentityProvider identityProvider = new CloudIdentityProvider (identity);
      // IObjectStorageProvider provider = new CloudBlockStorageProvider(testIdentity, "dfw", identityProvider, null);
      IObjectStorageProvider provider = new CloudFilesProvider(identityProvider);
      TestProtocolViolation(provider);
      Console.WriteLine ("Testing!");
      return 0;
    }

    public void TestProtocolViolation(IObjectStorageProvider provider)
    {
        try
        {
            TestTempUrlWithSpecialCharactersInObjectName(provider);
        }
        catch (WebException ex)
        {
            /* ServicePoint servicePoint = ServicePointManager.FindServicePoint(ex.Response.ResponseUri);
            FieldInfo table = typeof(ServicePointManager).GetField("s_ServicePointTable", BindingFlags.Static | BindingFlags.NonPublic);
            WeakReference weakReference = (WeakReference)((Hashtable)table.GetValue(null))[servicePoint.Address.GetLeftPart(UriPartial.Authority)];
            if (weakReference != null)
                weakReference.Target = null; */
        }

        TestTempUrlExpired(provider);
    }

        public void TestTempUrlExpired(IObjectStorageProvider provider)
        {
            string TestContainerPrefix = "sambug";

            string containerName = TestContainerPrefix + Path.GetRandomFileName();
            string objectName = Path.GetRandomFileName();
            string fileContents = "File contents!";

            Dictionary<string, string> accountMetadata = provider.GetAccountMetaData();
            string tempUrlKey;
            if (!accountMetadata.TryGetValue("Temp-Url-Key", out tempUrlKey))
            {
                tempUrlKey = Guid.NewGuid().ToString("N");
                accountMetadata = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                accountMetadata["Temp-Url-Key"] = tempUrlKey;
                provider.UpdateAccountMetadata(accountMetadata);
            }

            ObjectStore result = provider.CreateContainer(containerName);

            Stream stream = new MemoryStream(Encoding.UTF8.GetBytes(fileContents));
            provider.CreateObject(containerName, stream, objectName);

            // verify a past time does not work
            try
            {
                DateTimeOffset expirationTime = DateTimeOffset.Now - TimeSpan.FromSeconds(3);
                Uri uri = ((CloudFilesProvider)provider).CreateTemporaryPublicUri(HttpMethod.GET, containerName, objectName, tempUrlKey, expirationTime);
                WebRequest request = HttpWebRequest.Create(uri);
                using (WebResponse response = request.GetResponse())
                {
                    Stream cdnStream = response.GetResponseStream();
                    StreamReader reader = new StreamReader(cdnStream, Encoding.UTF8);
                    string text = reader.ReadToEnd();
                }
            }
            catch (WebException ex)
            {
                // Assert.AreEqual(HttpStatusCode.Unauthorized, ((HttpWebResponse)ex.Response).StatusCode);
            }

            provider.DeleteContainer(containerName, deleteObjects: true);
        }

    public void TestTempUrlWithSpecialCharactersInObjectName(IObjectStorageProvider provider)
        {
            string TestContainerPrefix = "sambug";
            string containerName = TestContainerPrefix + Path.GetRandomFileName();
            string objectName = "§ /\n\r 你好";
            string fileContents = "File contents!";

            Dictionary<string, string> accountMetadata = provider.GetAccountMetaData();
            string tempUrlKey;
            if (!accountMetadata.TryGetValue("Temp-Url-Key", out tempUrlKey))
            {
                tempUrlKey = Guid.NewGuid().ToString("N");
                accountMetadata = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                accountMetadata["Temp-Url-Key"] = tempUrlKey;
                provider.UpdateAccountMetadata(accountMetadata);
            }

            ObjectStore result = provider.CreateContainer(containerName);

            Stream stream = new MemoryStream(Encoding.UTF8.GetBytes(fileContents));
            provider.CreateObject(containerName, stream, objectName);

            // verify a future time works
            DateTimeOffset expirationTime = DateTimeOffset.Now + TimeSpan.FromSeconds(10);
            Uri uri = ((CloudFilesProvider)provider).CreateTemporaryPublicUri(HttpMethod.GET, containerName, objectName, tempUrlKey, expirationTime);
            WebRequest request = HttpWebRequest.Create(uri);
            using (WebResponse response = request.GetResponse())
            {
                Stream cdnStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(cdnStream, Encoding.UTF8);
                string text = reader.ReadToEnd();
            }

            provider.DeleteContainer(containerName, deleteObjects: true);
        }
  }
}
