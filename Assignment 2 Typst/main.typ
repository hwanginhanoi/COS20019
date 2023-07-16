#import "template.typ": *
#show: ieee.with(
  title: "COS20019 Assignment 2",
  abstract: [
   This paper presents an extended AWS infrastructure with an emphasis on improving interactions between EC2, Lambda, and S3 services. The goals include developing a Lambda function, using custom AMIs, implementing auto scaling with launch configurations, utilizing elastic load balancers, enforcing access control using AWS NACLs, and enforcing access control through S3 bucket policies. By accomplishing these goals, the infrastructure shows enhanced security, scalability, and performance, allowing effective interactions between EC2, Lambda, and S3 services inside the AWS environment.
  ],
  authors: (
    (
      name: "Luu Tuan Hoang",
      studentid: [104180391],
      class: [Tutor class: 8.00am Saturday],
      organization: [Swinburne University of Technology],
      location: [Hanoi, Vietnam],
      email: "104180391@student.swin.edu.au"
    ),
  ),
  index-terms: ("Cloud Computing", "System Architecture", "Cloud Service", "Computing Power"),
  bibliography-file: "refs.bib",
)

= Introduction
The Photo Album website project involves using EC2 web servers to host the website and a variety of AWS services, including S3, RDS, and Lambda. Users can upload photographs to the website, explore photo albums, and have thumbnails that have been automatically resized created. To integrate the website with the S3 bucket, RDS database, and Lambda function, the whole source code and instructions have been made available. This project uses the power of AWS services to create a dynamic and user-friendly picture album experience with features like photo retrieval, uploading, and thumbnail creation.

= Website Architecture

== Infrastructure requirements

=== Virtual Private Cloud (VPC) 
VPC configured with 2 Availability Zones (AZs) both with public and private subnets. The public subnets are associated with a route table that directs traffic to an Internet Gateway (IGW). On the other hand, the private subnets are associated with a separate route table that routes traffic to NAT gateway (In my architecture, I use NAT gateway instead of NAT instance).

#figure(
  image("asset/VPC Resource Map.png", width: 100%),
  caption: [
    VPC Resource Map (NAT Gateway included)
  ],
)
  <vpc_resource_map>

#figure(
  image("asset/VPC Subnet CIDR Block.png", width: 100%),
  caption: [
  VPC Subnet CIDR Block],
)
  <vpc_cidr_block>

The VPC is ready for the photo album web server to be launched.

=== Security group
There are a total of four security groups in the architecture: ELBSG, WebServerSG, DBServerSG, DevServerSG. Since NAT gateway is used instead of NAT instance, NATServerSG is not necessary. Outbound rule of all security group set to default (All traffic, anywhere IPv4).

#figure(
  image("asset/SG_W.png", width: 100%),
  caption: [
  WebServerSG Security Group],
)
  <sg_w>

#figure(
  image("asset/SG_DB.png", width: 100%),
  caption: [
  DBServerSG Security Group],
)
  <sg_db>

#figure(
  image("asset/SG_ELB.png", width: 100%),
  caption: [
  ELBSG Security Group],
)
  <sg_elb> 

#figure(
  image("asset/SG_D.png", width: 100%),
  caption: [
  DevServerSG Security Group],
)
  <sg_d>  

#figure(
  image("asset/SGA_DB.png", width: 100%),
  caption: [
  DBServerSG Security Group attached to RDS],
)
  <sga_d>  

  #figure(
  image("asset/SGA_ELB.png", width: 100%),
  caption: [
  ELBSG Security Group attached to ELB],
)
  <sga_elb>

#figure(
  image("asset/SGA_W.png", width: 100%),
  caption: [
  WebServerSG Security Group attached to Launch instance],
)
  <sga_w>  

#figure(
  image("asset/SGA_D.png", width: 100%),
  caption: [
  DevServerSG Security Group attached to Dev Server instance],
)
  <sga_d>  

#figure(
  image("asset/SG.png", width: 100%),
  caption: [
  Inbound security rules summary],
)
  <sg>  

The architecture is now secured well with least privillege principal.

=== Network ACL (NACL)
A Network Access Control List (NACL) called "PrivateSubnetsNACL" was created and implemented to improve the security of the web servers in the private subnets. This NACL's function is to limit ICMP (Internet Control Message Protocol) traffic going to and coming from the Dev Server in both directions.

#figure(
  image("asset/NACL Subnet Association.png", width: 100%),
  caption: [
  NACL associated with private subnets in the VPC],
)
  <nacl_association>

  ICMP protocol from Public Subnet 2 (CIDR 10.0.2.0/24) which Dev Server resides in is blocked, both inbound and outbound. Rules are listed in @nacl_inbound and @nacl_outbound.

#figure(
  image("asset/NACL Inbound Rules.png", width: 100%),
  caption: [
  Inbound rules of #emph[PrivateSubnetsNACL]],
)
  <nacl_inbound>

#figure(
  image("asset/NACL Outbound Rules.png", width: 100%),
  caption: [
    Outbound rules of #emph[PrivateSubnetsNACL]],
)
  <nacl_outbound>

  #figure(
  image("asset/NACL Test.png", width: 100%),
  caption: [
    Testing the NACL],
)
  <nacl_test>

To test the NACL, make SSH connection to Dev Server via elastic IP that was allocated for Dev Server. Ping to private IP of EC2 instance from Web Server ASG. Next, make SSH connection from Dev Server to EC2 instance with private IP address and ping to Dev Server #cite("pope_2014_securely"). From @nacl_test we can clearly see that the NACL is preventing any communication via ICMP packets to and from the Dev Server.
  
=== IAM Role 
The management console already has IAM roles with the necessary permissions called "LabRole" and "Labinstancerole" that can be used for this assignment.

#figure(
  image("asset/Lambda IAM Role.png", width: 100%),
  caption: [
  #emph[CreateThumbnail] Lambda function execution role
  ],
)  
<lambda_iam_role>

The Lambda function was permitted with an IAM execution role to ensure the proper security and permissions. The Lambda function is granted access to and control over the objects in the specified S3 bucket by the IAM role named #emph[LabRole], which was already created with the least privilege principle.

#figure(
  image("asset/Launch Template IAM Role.png", width: 100%),
  caption: [
  #emph[CreateThumbnail] Launch template IAM role
  ],
)  
<launch_template_iam_role>

Following the principle of least privilege, an IAM role named #emph[LabInstanceProfile] was created to grant the web server the required permissions. The role was set up to give the designated S3 bucket's designated Web Server the particular permissions needed to add objects to it and call the CreateThumbnail Lambda function.

=== Auto Scaling Group (ASG)
To create ASG, we need to create a Dev Server instance first, which is used to develop the custom AMI for the web server and make a launch template later.

==== Dev Server Instance
Dev server is not receiving traffic from ELB, as it serves as the platform solely for developing the custom AMI required to run the PhotoAlbum website. The custom AMI encompasses all the necessary components such as the AWS PHP SDK, Apache web server, and website source code. Additionally, the Dev server can manage MySQL RDS instance using phpMyAdmin.

#figure(
  image("asset/Dev Server Subnet.png", width: 100%),
  caption: [
  Dev Server instance resides in Public Subnet 2 (CIDR: 10.0.2.0/24) with an Elastic IP associated],
)
<dev_server_subnet>

Dev Server is configured with t2-micro as instance type using Amazon Linux 2 AMI (HVM), SSD Volume Type, with Apache Web Server installed using bash script in assignment 1a. IAM Role is LabRole, which is already created in AWS Learner Lab.

#figure(
  image("asset/Dev Server Configuration.png", width: 100%),
  caption: [
 Configuration of Dev Server EC2 instance],
)
<dev_server_config>

The Dev Server is associated with an Elasitc IP to allow SSH connection to manage Dev Server directory.

#figure(
  image("asset/EC2 Folder Structure.png", width: 100%),
  caption: [
  Dev Server Directory Structure with necessary SDKs and components included],
)
<dev_server_dir_struct>

#figure(
  image("asset/Dev Server Image.png", width: 100%),
  caption: [
  Dev Server image created, ready to use],
) 
<dev_server_ami>

==== Launch template 
Use the created image from @dev_server_ami to create new launch template with instance type #emph[t2.micro] and IAM role #emph[LabInstanceProfile] attached.

#figure(
  image("asset/Dev Server Image.png", width: 100%),
  caption: [
  Launch template for ASG],
) 
<launch_template>

==== Auto Scaling Group
The ASG is specifically configured to launch instances into the private subnets, maintaining a minimum of 2 instaces and a maximum of 3 instances, with 2 instances as the desired number. This ensures that the application has a minimum number of instances available at all times while also preventing the infrastructure from scaling beyond the defined maximum.

#figure(
  image("asset/ASG.png", width: 100%),
  caption: [
  ASG basic configuration],
) 
<asg>

#figure(
  image("asset/ASG Health Check.png", width: 100%),
  caption: [
  ASG health check configuration with target group attached],
) 
<asg_ht>

#figure(
  image("asset/Target Tracking Policy.png", width: 100%),
  caption: [
  Target tracking policy based on application load balancer request],
) 
<track_policy>

#figure(
  image("asset/ASG Network.png", width: 100%),
  caption: [
  ASG network mapped to private subnets],
) 
<asg_network>

To control the number of instances based on the number of requests received for each target in the ELB target group, a target tracking scaling policy was created (@track_policy). The policy is configured to maintain a target request count of 30. In order to maintain the desired request count per target, the auto-scaling group will automatically scale the number of instances up or down, ensuring optimal performance and effective resource utilization.

#figure(
  image("asset/ASG Working.png", width: 100%),
  caption: [EC2 instances properly distributed accross two private subnets with healthy states
  ],
) 
<asg_working>

Now the web server can dynamically adapt its capacity based on the request load, keeping a constant number of requests per target and maximizing resource utilization.

=== Elastic Load Balancing (ELB)
Firstly, create a new target group as load balancer need to routes requests to the targets in a target group and performs health checks on the targets.

#figure(
  image("asset/Target Group.png", width: 100%),
  caption: [
  Target group configuration, with health check path set to `/photoalbum/album.php`],
) 
<target_group>

Create a new load balancer and attach it to the target group.

#figure(
  image("asset/Load Balancer.png", width: 100%),
  caption: [
  Application Load Balancer mapped to Public Subnet 1 and Public Subnet 2],
) 
<elb>

#figure(
  image("asset/Load Balancer Listener.png", width: 100%),
  caption: [
  ELB Listener check rule which forward to targer group created in @target_group],
) 
<elb_listener>

Now The ELB can distribute incoming HTTP and HTTPS traffic across multiple EC2 targets.

=== Simple Storage Service (S3)
The S3 bucket has been created with almost the same configuration as the one used in assignment 1b, specifically for storing photos. To ensure proper accessibility of objects stored in this S3 bucket, appropriate permissions and policies have been applied. These measures guarantee that the necessary permissions are set up correctly to allow access to the stored photos as intended #cite("amazonwebservice_2023_bucket").

#figure(
  image("asset/S3.png", width: 100%),
  caption: [
    Properties of S3 bucket
  ],
)  
<s3_properties>

#figure(
  image("asset/S3 Policy.png", width: 100%),
  caption: [
    S3 policy to restrict access to a specific HTTP referer from Dev Server and Elastic Load Balancer
  ],
) 
<s3_policy>

In summary, this policy restricts access to the S3 bucket to only those GET requests originating from the specified domains, ensuring a controlled and secure access policy for the bucket's objects.

=== Lambda Fuction 
A Lambda function named "CreateThumbnail" was created using Python 3.7 as the runtime environment. 

#figure(
  image("asset/Lambda Configuration.png", width: 100%),
  caption: [
  #emph[CreateThumbnail] Lambda function configuration
  ],
)  
<lambda_config>

The "lambda-deployment-package.zip" deployment package was uploaded. The required library and complete source code for resizing images and processing downloads and uploads using the S3 bucket are both included in this package.

=== Relational Database Service (RDS)
The RDS instace use in this assignment is configured the same as the previous assignment. 

#figure(
  image("asset/RDS.png", width: 100%),
  caption: [
  RDS instance 
  ],
)  
<rds_config>

Configuration: 

-- Template: Free-tier

-- Database engine: MySQL Community 8.0.28

-- Public access set to No.

-- Use DBServerSG for VPC security group

-- AZ set to us-east-1a (According to the provided diagram).

-- The RDS instance is associated with a subnet group 
 #emph[dbsubnetgroup] which consists of private subnets in both AZs.

#figure(
  image("asset/RDS Subnet Group.png", width: 100%),
  caption: [
  Subnet #emph[dbsubnetgroup] with Private subnet 3 and Private subnet 4
  ],
)  
<rds_subnet_group>

#figure(
  image("asset/RDS Data.png", width: 100%),
  caption: [
  Data records of the database
  ],
)  
<rds_data>

== Functional requirements 

=== Website accessibility 

To access the PhotoAlbum website, use the following URL: http://104180391-assignment2elb-444083168.us-east-1.elb.amazonaws.com/photoalbum/album.php. It allows you to view and interact with the PhotoAlbum web application. Additionally, to upload photos and their associated metadata, utilize the PhotoUploader web page at http://104180391-assignment2elb-444083168.us-east-1.elb.amazonaws.com/photoalbum/photouploader.php. By using this page, multiple photos can be easily upload and input their corresponding metadata to enhance the functionality of the PhotoAlbum website.

 #figure(
  image("asset/ELB Link.png", width: 100%),
  caption: [
  Website accessible through ELB DNS
  ],
)  
<elb_link>

#figure(
  image("asset/Dev Link.png", width: 100%),
  caption: [
  Website is not accessible through Dev Server ec2-67-202-27-34.compute-1.amazonaws.com/photoalbum/album.php, as security group has blocked HTTP
  ],
)  
<dev_link>

Therefore, the website is only accessible through ELB.

=== Photo display function

#figure(
  image("asset/PhotoAlbumView.png", width: 100%),
  caption: [
  Photo display function
  ],
)  
<display>

Photo display function is working properly

=== Photo upload function

#figure(
  image("asset/PhotoUploading.png", width: 95%),
  caption: [
  Uploading photo
  ],
)  
<uploading>

#figure(
  image("asset/PhotoUploaded.png", width: 100%),
  caption: [
  Photo uploaded
  ],
)  
<uploaded>

Photo uploading function is working properly.

=== Resizing Lambda 

#figure(
  image("asset/PhotoResize.png", width: 95%),
  caption: [
  Photo uploaded
  ],
)  
<resize>
