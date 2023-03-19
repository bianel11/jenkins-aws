provider "aws" {
  region     = "us-east-1"
  access_key = file("./access_key.txt")
  secret_key = file("./secret_key.txt")
}

resource "aws_instance" "example" {
  ami             = "ami-005f9685cb30f234b"
  instance_type   = "t2.micro"
  security_groups = ["default"]
  key_name        = "terra-example"
  tags = {
    Name = "jenkins-aws"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ip.txt"
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("./terra-example.pem")
    }

    inline = [
      "set -o errexit",
      "sudo yum update -y",
      "sudo yum install git -y",
      "sudo wget https://releases.hashicorp.com/terraform/1.4.2/terraform_1.4.2_linux_amd64.zip",
      "unzip terraform_1.4.2_linux_amd64.zip",
      "sudo mv terraform /usr/local/bin",
      "sudo chmod +x /usr/local/bin/terraform",
      "terraform version", 
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
    ]
  }
}
