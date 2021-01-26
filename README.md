# Cloud Security - Secure the Recipe Vault Web Application
 
In this project, you will:
 
* Deploy and assess a simple web application environment’s security posture
* Test the security of the environment by simulating attack scenarios and exploiting cloud configuration vulnerabilities
* Implement monitoring to identify insecure configurations and malicious activity 
* Incrementally harden and secure the environment using various techniques to ensure the security of the data and infrastructure
* Design a DevSecOps pipeline which would enable the hardening to source controlled and automated
 
## Dependencies and Prerequisites
 
### Installation of the AWS CLI and Local Setup of AWS API keys
Instructions and examples in this project will make use of the AWS CLI in order to automate and reduce time and complexity.
Refer to the below links to get the AWS CLI installed and configured in your local environment.
 
[Installing the CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
 
[Configuring the CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
 

## Initial Environment - Prior to Hardening
  
The architecture of the environment, prior to hardening, is described by the diagam below. It includes a number of poor security practices, which were to be exploited via an attack simulation, before incrementally hardening the infrastructure.
 
![base environment](AWS-WebServiceDiagram-v1-insecure.png)
 
#### Expected user flow:
- Clients will invoke a public-facing web service to pull free recipes.  
- The web service is hosted by an HTTP load balancer listening on port 80.
- The web service is forwarding requests to the web application instance which listens on port 5000.
- The web application instance will, in turn, use the public-facing AWS API to pull recipe files from the S3 bucket hosting free recipes. An IAM role and policy will provide the web app instance permissions required to access objects in the S3 bucket.
- Another S3 bucket is used as a vault to store secret recipes; there are privileged users who would need access to this bucket. The web application server does not need access to this bucket.
 
#### Attack flow:
- Scripts simulating an attack will be run from a separate instance which is in an un-trusted subnet.
- The scripts will attempt to break into the web application instance using the public IP and attempt to access data in the secret recipe S3 bucket.

 
### Getting Started
Full instructions can be found [here](INSTRUCTIONS.md), but to get up and running quickly, run the following commands to deploy each of the three initial CloudFormation stacks, via the AWS CLI.
 
 
#### From the root directory of the repository - execute the below commands to deploy the templates.
 
##### Deploy the S3 buckets
```
aws cloudformation create-stack --region us-east-1 --stack-name c3-s3 --template-body file://src/c3-s3.yml
```
 
Expected example output:
```
{
    "StackId": "arn:aws:cloudformation:us-east-1:4363053XXXXXX:stack/c3-s3/70dfd370-2118-11ea-aea4-12d607a4fd1c"
}
```
##### Deploy the VPC and Subnets
```
aws cloudformation create-stack --region us-east-1 --stack-name c3-vpc --template-body file://src/c3-vpc.yml
```
 
Expected example output:
```
{
    "StackId": "arn:aws:cloudformation:us-east-1:4363053XXXXXX:stack/c3-vpc/70dfd370-2118-11ea-aea4-12d607a4fd1c"
}
```
 
##### Deploy the Application Stack 
You will need to specify a pre-existing key-pair name.
```
aws cloudformation create-stack --region us-east-1 --stack-name c3-app --template-body file://src/c3-app.yml --parameters ParameterKey=KeyPair,ParameterValue=<add your key pair name here> --capabilities CAPABILITY_IAM
```
 
Expected example output:
```
{
    "StackId": "arn:aws:cloudformation:us-east-1:4363053XXXXXX:stack/c3-app/70dfd370-2118-11ea-aea4-12d607a4fd1c"
}
```
 
#### Upload data to S3 buckets
Upload the free recipes to the free recipe S3 bucket from step 2. Do this by typing this command into the console (you will replace `<BucketNameRecipesFree>` with your bucket name):
 
Example:  
```
aws s3 cp free_recipe.txt s3://<BucketNameRecipesFree>/ --region us-east-1
```
 
Upload the secret recipes to the secret recipe S3 bucket from step 2. Do this by typing this command into the console (you will replace `<BucketNameRecipesSecret>` with your bucket name):
 
Example:  
```
aws s3 cp secret_recipe.txt s3://<BucketNameRecipesSecret>/ --region us-east-1
```
 
#### Test the application
Invoke the web service using the application load balancer URL:
```
http://<ApplicationURL>/free_recipe
```
You should receive a recipe for banana bread.

The AMIs specified in the cloud formation template exist in the us-east-1 (N. Virginia) region. You will need to set this as your default region when deploying resources for this project.
 
###  Identification of Bad Practices
 
Based on the architecture diagram, and the steps taken to upload data and access the application web service, an initial observation of poor security practices were listed in the text file named E1T4.txt.
 
**Deliverables:** 
- **E1T4.txt** - Text file identifying 2 poor security practices with justification. 
 
## Part 2: Enable Security Monitoring
 
 
### Security Monitoring using AWS Native Tools
 
Security monitoring was set-up to ensure that the AWS account and environment configuration is in compliance with the CIS standards for cloud security. The following AWS services were used:

- AWS Config
- AWS Inspector
- AWS GuardDuty
- AWS SecurityHub
 
### Identify and Triage Vulnerabilities
  
Vulnerabilities related to the code that was deployed for the environment in this project were identified, along with recommendations on how to remediate them E2T2.txt
 
**Deliverables:** 
- **E2T2_config.png** - Screenshot of AWS Config showing non-compliant rules.
- **E2T2_inspector.png** - Screenshot of AWS Inspector showing scan results.
- **E2T2.png_securityhub.png** - Screenshot of AWS Security Hub showing compliance standards for CIS foundations.
- **E2T2.txt** - Identified vulerabilities and potential steps to remediate them.
 
## Part 3 - Attack Simulation
 
The following scripts were exectured in order to simulate the following attack conditions:
- Making an SSH connection to the application server using brute force password cracking.
- Capturing "secret" files from the s3 bucket using stolen API keys.
 
### Brute force attack to exploit SSH ports facing the internet and an insecure configuration on the server

The attack simulation was carried out from the EC2 "Attack Instance" by logging in ot the instance via SSH key pair as follows:

```
ssh -i <private key file> ubuntu@<AttackInstanceIP>
```
 

The following commands were then executed in order to start a brute force attack against the application server, using a tool called Hydra - already installed on the Attack Instance image. (The application server hostname is required for this).
```
date
hydra -l ubuntu -P rockyou.txt ssh://<ApplicationServerDnsNameHere>
```
 
Wait 10 - 15 minutes and check AWS Guard Duty.
 
#### 3. Answer the following questions:
1. What findings were detected related to the brute force attack?
2. Take a screenshot of the Guard Duty findings specific to the attack. Title this screenshot E3T1_guardduty.png.
3. Research the AWS Guard Duty documentation page and explain how GuardDuty may have detected this attack - i.e. what was its source of information?
 
Submit text answers in E3T1.txt.
 
**Deliverables:**
- **E3T1_guardduty.png** - Screenshot of Guard Duty findings specific to the Exercise 3, Task 1 attack.
- **E3T1.txt** - Answer to the questions at the end of Exercise 3, Task 1.
 
### Task 2: Accessing Secret Recipe Data File from S3
 
Imagine a scenario where API keys used by the application server to read data from S3 were discovered and stolen by the brute force attack.  This provides the attack instance the same API privileges as the application instance.  We can test this scenario by attempting to use the API to read data from the secrets S3 bucket.
 


