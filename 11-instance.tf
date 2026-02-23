resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }

  depends_on = [data.aws_ami.amazon_linux, aws_security_group.bastion_sg, aws_key_pair.deployer, aws_subnet.public_subnet]
}

resource "aws_network_interface" "bastion_private_eni" {
  subnet_id       = aws_subnet.private_subnet[0].id
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-private-eni"
  }
}

resource "aws_network_interface_attachment" "bastion_private_attach" {
  instance_id          = aws_instance.bastion.id
  network_interface_id = aws_network_interface.bastion_private_eni.id
  device_index         = 1
}

resource "aws_eip" "bastion_eip" {
  instance   = aws_instance.bastion.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gateway]
}

output "bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "bastion_ssh" {
  value = "ssh ec2-user@${aws_eip.bastion_eip.public_ip}"
}
