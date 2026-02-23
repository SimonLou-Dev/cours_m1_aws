##############################
#                            #
#           bastion          #
#                            #
##############################
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_ssh" {
  value = "ssh ec2-user@${aws_instance.bastion.public_ip}"
}

##############################
#                            #
#        loadbalancer        #
#                            #
##############################

output "lb_dns" {
  value = "http://${aws_lb.nginx_lb.dns_name}"
}