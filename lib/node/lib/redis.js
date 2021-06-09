const redis = require('redis');
const util = require('util');

const REDIS_HOST = process.env.REDIS_HOST || 'redis';
const REDIS_PORT = process.env.REDIS_PORT || '6379';

// commands we want to wrap in promises, feel free to add to this list
const promisify = ['get', 'set', 'del', 'keys', 'expire', 'send_command', 'save'];

class RedisClient {

  _initClient() {
    this.client = redis.createClient({
      host: REDIS_HOST,
      port : REDIS_PORT
    });

    // Node Redis currently doesn't natively support promises (this is coming in v4)
    promisify.forEach(key => this.client[key] = util.promisify(this.client[key]));

    this.client.on('error', (err) => {
      console.error('Redis client error', err);
    });
    this.client.on('ready', () => {
      console.log('Redis client ready');
    });
    this.client.on('end', () => {
      console.log('Redis client closed connection');
    });
    this.client.on('reconnecting', () => {
      console.log('Redis client reconnecting');
    });
  }

  /**
   * @method connect
   * @description create/connect redis client
   */
  connect() {
    if( !this.client ) this._initClient();
  }

  /**
   * @method disconnect
   * @description disconnect redis client
   * 
   * @returns {Promise}
   */
  disconnect() {
    return new Promise((resolve, reject) => {
      this.client.quit(() => resolve());
    });
  }

}

module.exports = new RedisClient();