module "ecs" {
  source = "./modules/ecs"

  cluster_name = var.prefix
}

module "ec2" {
  source = "./modules/ec2"

  prefix                    = var.prefix
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  instance_type             = var.instance_type
  max_number_of_instances   = var.max_number_of_instances
  min_number_of_instances   = var.min_number_of_instances
  instance_root_volume_size = var.instance_root_volume_size
  instance_ingress          = var.instance_ingress
  ssh_whitelist             = var.ssh_whitelist
  public_key_path           = var.public_key_path
  ecs_cluster               = module.ecs.cluster_id
}
