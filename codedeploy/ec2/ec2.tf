resource "aws_instance" "ec2" {
	# Amazon Linux 2
	ami                                  = "ami-0ffac3e16de16665e"
    iam_instance_profile                 = data.aws_iam_role.ec2_role.name
    instance_type                        = "t2.micro"
    key_name                             = var.key_name
    source_dest_check                    = true
    subnet_id                            = var.subnet
    tags                                 = {
        "Name" = "${var.project}-instance"
    }
    tags_all                             = {
        "Name" = "${var.project}-instance"
    }
    tenancy                              = "default"
    user_data                            = file("userdata.sh")
    vpc_security_group_ids               = [
        var.vpc_sg,
    ]
}
