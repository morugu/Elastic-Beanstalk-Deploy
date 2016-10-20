if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_ACCESS_KEY" ]; then
  error 'Please specify key'
  exit 1
fi

if [ ! -n "$WERCKER_ELASTIC_BEANSTALK_DEPLOY_SECRET_KEY" ]; then
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

info 'Installing pip...'
sudo apt-get install -y python-pip libpython-all-dev

info 'Installing the AWS CLI...';
sudo pip install awscli;

info 'EB Version...'
eb --version

mkdir -p $HOME/.aws
echo '[default]' > $HOME/.aws/config
echo 'output = json' >> $HOME/.aws/config
echo "region = $WERCKER_ELASTIC_BEANSTALK_DEPLOY_REGION" >> $HOME/.aws/config
echo "aws_access_key_id = $WERCKER_ELASTIC_BEANSTALK_DEPLOY_ACCESS_KEY" >> $HOME/.aws/config
echo "aws_secret_access_key = $WERCKER_ELASTIC_BEANSTALK_DEPLOY_SECRET_KEY" >> $HOME/.aws/config

export AMAZON_ACCESS_KEY_ID=$WERCKER_ELASTIC_BEANSTALK_DEPLOY_ACCESS_KEY
export AMAZON_SECRET_ACCESS_KEY=$WERCKER_ELASTIC_BEANSTALK_DEPLOY_SECRET_KEY
export AWS_DEFAULT_REGION=$WERCKER_ELASTIC_BEANSTALK_DEPLOY_REGION
export AWS_APP_VERSION_LABEL=$WERCKER_GIT_BRANCH
export EB_DESCRIPTION=$WERCKER_EB_DEPLOY_ENV_NAME,$WERCKER_GIT_BRANCH

pwd
