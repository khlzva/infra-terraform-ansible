# Terraform 

**Provider:** Yandex Cloud

**VMs image:** Debian 11

### Virtual Private Cloud

- one network
- three subnets in two different zones: 
`[192.168.10.0/24], [192.168.11.0/24] - ru-central1-a`,
`[192.168.12.0/24] - ru-central1-b`

### VMs

Seven VMs placed in three subnets:

- **bastion**       – 192.168.10.101
- **grafana**       – 192.168.10.102
- **kibana**        – 192.168.10.103
- **web1**          – 192.168.11.101
- **prometheus**    – 192.168.11.102
- **elasticsearch** – 192.168.11.103
- **web2**          – 192.168.12.101

VMs in the first subnet `[192.168.10.0/24]` use NAT, the rest ones do not use it

### Application Load Balancer

Target group is two web hosts in different zones - `192.168.11.101` and `192.168.12.101`

Everything else is almost default configuration from terraform registry documentation

### Security Group

Some rules to allow ingress traffic: web, prometheus (node-exporter, nginxlog-exporter), grafana, elsaticsearch and kibana ports. 
Also there are rules for ICMP and SSH

And egress rule for all the traffic

### To use

Need to add to `main.tf`: 
1. yandex cloud IDs:
```
provider "yandex" {
  token     = "token"
  cloud_id  = "cloud_id"
  folder_id = "folder_id"
  zone      = "ru-central1"
}
```
2. image ID to VMs boot disks
```
boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 4
    }
}
```
3. pub ssh key to `meta.yaml`

# Ansible






