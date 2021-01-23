aws cloudformation create-stack --region us-east-1 --stack-name c3-s3 --template-body file://src/c3-s3.yml
aws cloudformation create-stack --region us-east-1 --stack-name c3-vpc --template-body file://src/c3-vpc.yml
aws cloudformation create-stack --region us-east-1 --stack-name c3-app --template-body file://src/c3-app.yml --parameters ParameterKey=KeyPair,ParameterValue=cand-c3-p3 --capabilities CAPABILITY_IAM

aws s3 cp free_recipe.txt s3://cand-c3-free-recipes-943664886747/ --region us-east-1
aws s3 cp secret_recipe.txt s3://cand-c3-secret-recipes-943664886747/ --region us-east-1

aws cloudformation update-stack --region us-east-1 --stack-name c3-s3 --template-body file://src/c3-s3-solution.yml