Authenticate with openstack and use like this:
```hcl
module "github_runner" {
  source      = "github.com/ba-work/openstack-github-runner"
  labels      = ["my", "cool", "labels"]
  repository  = "owner/repo" # github.com/owner/repo
  admin_group = "unix-group-for-admins"
  # optionally add proxy settings
  # proxy_settings = {
  #   proxy    = "http://my.corp.proxy"
  #   no_proxy = ".domain,.another" # no_proxy is optional within proxy_settings
  # }
}
```
