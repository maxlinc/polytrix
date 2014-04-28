package main

import (
	"fmt"
	"github.com/rackspace/gophercloud"
	"os"
)

func getCredentials() (provider, username, apiKey string) {
	provider = os.Getenv("RAX_AUTH_URL") + "/v2.0/tokens"
	username = os.Getenv("RAX_USERNAME")
	apiKey = os.Getenv("RAX_API_KEY")

	/*
	  if (provider == "") || (username == "") || (password == "") {
	    fmt.Fprintf(os.Stderr, "One or more of the following environment variables aren't set:\n")
	    fmt.Fprintf(os.Stderr, "  SDK_PROVIDER=\"%s\"\n", provider)
	    fmt.Fprintf(os.Stderr, "  SDK_USERNAME=\"%s\"\n", username)
	    fmt.Fprintf(os.Stderr, "  SDK_PASSWORD=\"%s\"\n", password)
	    os.Exit(1)
	  } */

	return
}

func withIdentity(ar bool, f func(gophercloud.AccessProvider)) {
	provider, username, apiKey := getCredentials()
	acc, err := gophercloud.Authenticate(
		provider,
		gophercloud.AuthOptions{
			Username:    username,
			ApiKey:      apiKey,
			AllowReauth: ar,
		},
	)
	if err != nil {
		panic(err)
	}

	f(acc)
}

func withServerApi(acc gophercloud.AccessProvider, f func(gophercloud.CloudServersProvider)) {
	api, err := gophercloud.ServersApi(acc, gophercloud.ApiCriteria{
		Name:      "cloudServersOpenStack",
		VersionId: "2",
		UrlChoice: gophercloud.PublicURL,
	})
	if err != nil {
		panic(err)
	}

	f(api)
}

func main() {
	withIdentity(false, func(auth gophercloud.AccessProvider) {
		withServerApi(auth, func(servers gophercloud.CloudServersProvider) {
			images, err := servers.ListImages()
			if err != nil {
				panic(err)
			}

			fmt.Println("ID,Name,MinRam,MinDisk")
			for _, image := range images {
				fmt.Printf("%s,\"%s\",%d,%d\n", image.Id, image.Name, image.MinRam, image.MinDisk)
			}
		})
	})
}
