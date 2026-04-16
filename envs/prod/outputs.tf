output "load_balancer_ip" {
  value = module.loadbalancer.public_ip
}

output "vm_private_ips" {
  value = module.compute.vm_private_ips
}