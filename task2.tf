//connection with aws


provider "aws"{ 
   profile    = "Anand"    //Enter your profile name which set at cli login 
   region     = "ap-south-1"
   
}  


//connection with aws end
//creating security grp start


resource "aws_security_group" "cpsec"{
    name        = "cpterasecty2"
    ingress{
          description = "TLS from VPC"
          from_port   = 80
          to_port     = 80
          protocol    = "TCP"
          cidr_blocks = ["0.0.0.0/0"]
      }
    ingress{
           description = "TLS from VPC"


           from_port   = 22
           to_port     = 22
           protocol    = "TCP"
           cidr_blocks = ["0.0.0.0/0"]
      }
    egress{
           from_port   = 0
           to_port     = 0
           protocol    = "-1"
           cidr_blocks = ["0.0.0.0/0"]
      }


    tags ={
           Name = "cpterasecty2"
      }
}


//creating security grp for efs end


//creating security grp for ec2 start


resource "aws_security_group" "mysecos"{
    name        = "teraasecos"     // you can change name
    ingress{
          description = "TLS from VPC"
          from_port   = 80
          to_port     = 80
          protocol    = "TCP"
          cidr_blocks = ["0.0.0.0/0"]
      }
    ingress{
           description = "TLS from VPC"
           from_port   = 22
           to_port     = 22
           protocol    = "TCP"
           cidr_blocks = ["0.0.0.0/0"]
      }
    egress{
           from_port   = 0
           to_port     = 0
           protocol    = "-1"
           cidr_blocks = ["0.0.0.0/0"]
      }




    tags ={
           Name = "terrasecos"         //give tag if you want
      }
}


//creating security grp end


//creating efs start


resource "aws_efs_file_system" "myefscp" {
  creation_token = "terraefscp"    //give name if you want


  tags = {
    Name = "terraefscp"           //give tag if you want
  }
}


output"efs_op"{
     value=aws_efs_file_system.myefscp
  }


resource "aws_efs_mount_target" "mymntscpa" {
  file_system_id = aws_efs_file_system.myefscp.id
  subnet_id      = "subnet-b50376f9"             //Enter your subnet id
  security_groups = [aws_security_group.cpsec.id]
}


resource "aws_efs_mount_target" "mymntscpb" {
  file_system_id = aws_efs_file_system.myefscp.id
  subnet_id      = "subnet-dce1e5b4"              //Enter your subnet id     
  security_groups = [aws_security_group.cpsec.id]
}


resource "aws_efs_mount_target" "mymntscpc" {
  file_system_id = aws_efs_file_system.myefscp.id
  subnet_id      = "subnet-f5f04f8e"              //Enter your subnet id 
  security_groups = [aws_security_group.cpsec.id]
}


output"a"{
     value=aws_efs_mount_target.mymntscpa
  }
  output"b"{
     value=aws_efs_mount_target.mymntscpb
  }
  output"c"{
     value=aws_efs_mount_target.mymntscpc
  }


//creating instance


resource "aws_instance" "cpins"{


depends_on = [
          aws_efs_mount_target.mymntscpc,
          ]


    ami     = "ami-0447a12f28fddb066" //enter ami/os image id if you want another os(now it is amazon linux)
    instance_type   ="t2.micro" 
    //subnet_id = "subnet-22edd74a"     I am launching the instance in ap-south-1a subnet of mumbai region you can change it
    security_groups =[aws_security_group.mysecos.name]
    key_name  ="mykey1"                //enter key_pair name you created at aws console


    tags ={
        Name = "terrains"
      }
}


 //to print details of instance


output"ins_i_pi"{
     value=aws_instance.cpins.public_ip
  }


//to print details of instance end
//creating instance end
//to launch server




//to lauch server


resource "null_resource" "runserver"{


depends_on = [
           aws_instance.cpins,
          ]


connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/KIIT/Downloads/mykey1.pem")  
    host     = aws_instance.cpins.public_ip
  }


provisioner "remote-exec"{
    inline = [
      "sudo yum install httpd git amazon-efs-utils -y ", 
      "sudo systemctl restart httpd", 
      "sudo systemctl enable httpd",
      "sudo mount -t efs ${aws_efs_file_system.myefscp.id}:/ /var/www/html", 
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/anand1501/Hybrid-Multicloud_Task-2.git /var/www/html/"  //edit the path of source code enter your site path  	
    ]
  }


}


resource "null_resource" "downloads_IP"{


    depends_on = [
    null_resource.runserver,
    ]
    provisioner "local-exec"{
          command = "echo ${aws_instance.cpins.public_ip} > yourdomain.text "   //you will get your ip address in "yourdomain.txt" file in directory where you run this code    
      }
  }
