const { Authenticator } = require('cognito-at-edge');
const Env = require('dotenv').config();

const authenticator = new Authenticator({
  region: 'ap-northeast-1', // user pool region
  userPoolId: process.env.USER_POOL_ID, // user pool ID
  userPoolAppId: process.env.USER_POOL_APP_ID, // user pool app client ID
  userPoolDomain: process.env.USER_POOL_APP_DOMAIN, // user pool domain
  cookiePath: '/',
});

exports.handler = async (request) => authenticator.handle(request);
