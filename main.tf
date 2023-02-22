terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
 }
}


resource "aws_instance" "example" {
  #ami           = "ami-033594f8862b03bb2"
  #ami           = "ami-0f1ee03d06c4c659c"
  ami           = "ami-0c2b0d3fb02824d92"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name = "terraform-key"
  security_groups = ["${aws_security_group.allow_rdp.name}"]
  user_data                   = data.template_file.userdata_powershell.rendered



}

data "template_file" "userdata_powershell" {

  template = <<EOF
<powershell>
start-transcript
$dlurl = "https://awscli.amazonaws.com/AWSCLIV2-2.0.30.msi"
$installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
Invoke-WebRequest $dlurl -OutFile $installerPath
Start-Process -FilePath msiexec -Args "/i $installerPath /passive" -Verb RunAs -Wait
mkdir C:\temp
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
aws s3 cp s3://myawsbucketadam1987/ C:\temp --recursive
##Start-Process  -Filepath "C:\temp\jdk-11.0.15.1_windows-x64_bin.exe"  -ArgumentList '/s' -PassThru
##[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\temp\jdk-11.0.17+8\bin")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
#C:\temp\java_path.ps1
##[System.Environment]::SetEnvironmentVariable("Path", [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";$($env:JAVA_HOME)")
##$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
###[Environment]::SetEnvironmentVariable("JAVA_HOME","C:\temp\jdk-11.0.17+8\bin",[System.EnvironmentVariableTarget]::Machine)
###[Environment]::SetEnvironmentVariable("PATH",[Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine)+";C:\temp\jdk-11.0.17+8\bin",[System.EnvironmentVariableTarget]
###$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
####[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\temp\jdk-11.0.17+8\bin;", [System.EnvironmentVariableTarget]::Machine)
####[System.Environment]::GetEnvironmentVariable("JAVA_HOME", [System.EnvironmentVariableTarget]::Machine)
####[System.Environment]::SetEnvironmentVariable("Path", "%JAVA_HOME%;" + [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine), [System.EnvironmentVariableTarget]::Machine)
####[System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
####[System.Environment]::SetEnvironmentVariable("Path", "C:\temp\jdk-11.0.17+8\bin;" + [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine), [System.EnvironmentVariableTarget]::Machine)
####[System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
</powershell>
EOF
}


resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}



resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}



  resource "aws_security_group" "allow_rdp" {
  name        = "allow_rdp"
  description = "Allow ssh traffic"


  ingress {

    from_port   = 3389 #  By default, the windows server listens on TCP port 3389 for RDP
    to_port     = 3389
    protocol =   "tcp"

    cidr_blocks =  ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }



}

      
