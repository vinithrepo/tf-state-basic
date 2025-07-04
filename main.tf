
resource "aws_instance" "instance" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = var.security_groups

  tags = {
    Name = var.name
  }
}
resource "aws_route53_record" "record" {
  zone_id    = var.zone_id
  name       = "${var.name}-dev.vinithaws.online"
  type       = "A"
  ttl        = 30
  records    = [aws_instance.instance.private_ip]
}

resource "null_resource" "ansible" {
  depends_on = [aws_route53_record.record]
  provisioner "local-exec" {
    command = <<EOF

#cd /home/centos/roboshop-ansible
cd /home/ec2-user/roboshop-ansible
git pull
sleep 60
ansible-playbook -i ${var.name}-dev.vinithaws.online, main.yml -e ansible_user=ec2-user -e ansible_password=DevOps321 -e component=${var.name}

EOF
  }
}