if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_KEY" ]; then
  error 'Please specify key'
  exit 1
fi

if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_SECRET" ]; then
  error 'Please specify secret'
  exit 1
fi

if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_APP_NAME" ]; then
  error 'Please specify app-name'
  exit 1
fi

if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_ENV_NAME" ]; then
  error 'Please specify env-name'
  exit 1
fi

if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_REGION" ]; then
  error 'Please specify region'
  exit 1
fi

if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_BUCKET" ]; then
  #set default bucket as elasticbeanstalk
  export WERCKER_ELASTIC_BEANSTALK_DEPLOY_BUCKET="wercker-deployments"
fi

info 'Installing pip...'
sudo apt-get update
sudo apt-get install -y python-pip libpython-all-dev zip

info 'Installing the AWS CLI...';
sudo pip install awscli;

info 'EB Version...'
aws --version

mkdir -p $HOME/.aws
echo '[default]' > $HOME/.aws/config
echo 'output = json' >> $HOME/.aws/config
echo "region = $WERCKER_ELASTIC_BEANSTALK_DEPLOY_REGION" >> $HOME/.aws/config
echo "aws_access_key_id = $WERCKER_ELASTIC_BEANSTALK_DEPLOY_KEY" >> $HOME/.aws/config
echo "aws_secret_access_key = $WERCKER_ELASTIC_BEANSTALK_DEPLOY_SECRET" >> $HOME/.aws/config

export AMAZON_ACCESS_KEY_ID=$WERCKER_ELASTIC_BEANSTALK_DEPLOY_KEY
export AMAZON_SECRET_ACCESS_KEY=$WERCKER_ELASTIC_BEANSTALK_DEPLOY_SECRET
export AWS_DEFAULT_REGION=$WERCKER_ELASTIC_BEANSTALK_DEPLOY_REGION
export AWS_APP_VERSION_LABEL=$WERCKER_GIT_BRANCH
export AWS_APP_FILENAME=$AWS_APP_VERSION_LABEL.zip

zip -r $AWS_APP_FILENAME .

if [ ! -f $AWS_APP_FILENAME ]; then
  error 'Zip could not be created'
  exit 1
fi

aws s3 cp --acl private $AWS_APP_FILENAME s3://$WERCKER_ELASTIC_BEANSTALK_DEPLOY_BUCKET

aws elasticbeanstalk create-application-version \
    --application-name $WERCKER_ELASTIC_BEANSTALK_DEPLOY_APP_NAME \
    --version-label $AWS_APP_VERSION_LABEL \
    --region $WERCKER_ELASTIC_BEANSTALK_DEPLOY_REGION \
    --source-bundle S3Bucket="$WERCKER_ELASTIC_BEANSTALK_DEPLOY_BUCKET",S3Key="$AWS_APP_FILENAME"

aws elasticbeanstalk update-environment \
    --application-name $WERCKER_ELASTIC_BEANSTALK_DEPLOY_APP_NAME \
    --environment-name $WERCKER_ELASTIC_BEANSTALK_DEPLOY_ENV_NAME \
    --version-label $AWS_APP_VERSION_LABEL
