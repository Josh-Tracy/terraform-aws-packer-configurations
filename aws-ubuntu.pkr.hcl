packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws"
  instance_type = "t2.micro"
  region        = "us-east-1"
  ami_description = "packer built ubuntu"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

    provisioner "shell" {
      environment_vars = [
        "FOO=hello world",
      ]
      inline = [
        "echo Installing ansible",
        "sleep 5",
        "sudo apt -y install software-properties-common",
        "sudo apt-get update",
        "sudo apt -y install ansible",
        "echo \"FOO is $FOO\" > example.txt",
      ]
    }

# This provisioner is different from ansible-remote in that it will not run against remote nodes
    provisioner "ansible-local" {
      playbook_file = "ansible/webserver.yml"
      role_paths = ["ansible/roles"]
    }
  }
