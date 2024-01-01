data "template_file" "user_data_template" {
  template = file("${path.module}/user_data.tmpl")

  vars = {
    HOST     = aws_db_instance.rds_instance.address
    USERNAME = "admin"
    # Add other variables as needed
  }
}

# Launch Configuration
resource "aws_launch_template" "asg_launch_template" {
  name          = "asg-launch-config"
  image_id      = data.aws_ami.custom_ami.id
  instance_type = "t2.micro"
  key_name                = "ADMIN_KEYPAIR"
  ebs_optimized           = false
  disable_api_termination = false

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app-sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 10
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ebs_kms_key.arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Webapp EC2 Instance"
    }
  }
  user_data = base64encode(data.template_file.user_data_template.rendered)

#   user_data = base64encode(<<-EOF


#     #!/bin/bash  
#     source env_variables.sh 
#     sudo -i
#     sudo yum update -y
#     sudo yum upgrade -y
#     yum install java git tree -y
#     wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.97/bin/apache-tomcat-8.5.97.tar.gz
#     tar -xzf apache-tomcat-8.5.97.tar.gz
#     mv apache-tomcat-8.5.97 tomcat
#     cp -R tomcat /usr/local/
#     cd /usr/local/tomcat/bin/
#     ./catalina.sh start
#     cd
#     sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
#     sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
#     sudo dnf install mysql-community-server -y
#     git clone -b master https://github.com/Gangadhar-7/Java-Mysql-Simple-Login-Web-application.git
#     cd Java-Mysql-Simple-Login-Web-application/
#     echo -e "[client]\nuser=admin\npassword=admin123" > ~/.my.cnf
#     chmod 600 ~/.my.cnf 
#     export MYSQL_PWD='admin123' 
#     mysql -h "${HOST}" -P 3306 -u admin < database.sql
#     yum install maven -y
#     mvn clean install
#     cp target/LoginWebApp.war /usr/local/tomcat/webapps
#     cd /usr/local/tomcat/bin/
#     ./catalina.sh start

#     EOF
#   )

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}


# Auto Scaling Group
resource "aws_autoscaling_group" "webapp_asg" {
  name                = "webapp-asg"
  target_group_arns   = [aws_lb_target_group.webapp_tg.arn]
  vpc_zone_identifier = [for s in aws_subnet.public-subnet : s.id]
  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }
  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 120
  default_cooldown          = 60
  tag {
    key                 = "Name"
    value               = "WebApp EC2 Instance"
    propagate_at_launch = true
  }
}

# Scale up policy
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "webapp_scale-up-policy"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
}

# Scale down policy
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "webapp_scale-down-policy"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
}
