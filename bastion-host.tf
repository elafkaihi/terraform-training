resource "aws_instance" "bastion_host" {
  ami           = lookup(var.AMIS, var.AWS_REGION) # Replace with a valid Ubuntu AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.vprofilekey.key_name
  count         = var.instance_count

  associate_public_ip_address = true  # Ensure the instance has a public IP

  security_groups = [
    aws_security_group.vprofile-bastion-sg.id
  ]

  tags = {
    Name    = "vprofile-bastion"
    PROJECT = "vprofile"
  }

  provisioner "file" {
    content     = templatefile("db-deploy.tmpl", { rds-endpoint = aws_db_instance.vprofile-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/vprofile-dbdeploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vprofile-dbdeploy.sh",
      "sudo /tmp/vprofile-dbdeploy.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }
  depends_on = [aws_db_instance.vprofile-rds]
}

