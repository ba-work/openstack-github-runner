data "openstack_networking_network_v2" "floating" {
  name = var.floating_network
}

data "openstack_networking_subnet_v2" "floating" {
  name       = var.floating_subnet
  network_id = data.openstack_networking_network_v2.floating.id
}

data "openstack_images_image_v2" "image" {
  name        = var.image.name
  visibility  = var.image.visibility
  most_recent = true
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

data "openstack_keymanager_secret_v1" "token" {
  name = var.personal_access_token_secret
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/setup.sh", {
      repo           = var.repository
      token          = data.openstack_keymanager_secret_v1.token.payload
      labels         = join(",", var.labels)
      proxy_settings = var.proxy_settings
      admin_group    = var.admin_group
    })
  }

}
