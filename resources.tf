resource "openstack_networking_network_v2" "network" {
  port_security_enabled = false
}

resource "openstack_networking_subnet_v2" "subnet" {
  network_id      = openstack_networking_network_v2.network.id
  dns_nameservers = data.openstack_networking_subnet_v2.floating.dns_nameservers
  cidr            = var.cidr
}

resource "openstack_networking_router_v2" "router" {
  external_network_id = data.openstack_networking_network_v2.floating.id
  enable_snat         = true

  external_fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.floating.id
  }
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_compute_instance_v2" "vm" {
  depends_on = [openstack_networking_router_interface_v2.router_interface]
  name       = local.named_resources_string
  flavor_id  = data.openstack_compute_flavor_v2.flavor.id
  user_data  = data.cloudinit_config.cloud_init.rendered
  metadata   = {}

  network {
    uuid = openstack_networking_network_v2.network.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    volume_size           = var.volume_size
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = var.floating_network
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.vm.id
}
