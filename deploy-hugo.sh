cd hugo-site

# This is the location of the Hugo config.toml
CONFIG_FILE=config.toml

# Read the output from the WebsiteInfra the get the S3 Bucket name
S3_BUCKET=$(dasel -f ${ATTINI_INPUT} -w plain 'output.WebsiteInfra.Bucket')

# Get our custom domain from the DomainName parameter
DOMAIN=$(dasel -f ${ATTINI_INPUT} -w plain 'stackParameters.DomainName')
if [[ -z ${DOMAIN} ]]; then
  # If our custom domain is empty, use the CloudFront URL
  DOMAIN=$(dasel -f ${ATTINI_INPUT} -w plain 'output.WebsiteInfra.CloudFrontDomainName')
fi

# https://gohugo.io/getting-started/configuration/#configure-with-environment-variables
export HUGO_BASEURL="https://${DOMAIN}"

# Configure Hugo deployment target according to this site: https://gohugo.io/hosting-and-deployment/hugo-deploy/
dasel put -f ${CONFIG_FILE} -v "s3://${S3_BUCKET}?region=${AWS_REGION}&s3ForcePathStyle=true" 'deployment.targets.URL'
dasel put -f ${CONFIG_FILE} -v "deploying-to-${ATTINI_ENVIRONMENT_NAME}" 'deployment.targets.name'

CLOUDFRONT_ID=$(dasel -f ${ATTINI_INPUT} -w plain 'output.WebsiteInfra.CloudFrontId')
dasel put -f ${CONFIG_FILE} -v "${CLOUDFRONT_ID}" 'deployment.targets.cloudFrontDistributionID'

# Build the Hugo site
hugo --config ${CONFIG_FILE}
# Deploy the Hugo site
hugo deploy --target "deploying-to-${ATTINI_ENVIRONMENT_NAME}" --config ${CONFIG_FILE}


echo "See the site at $HUGO_BASEURL"