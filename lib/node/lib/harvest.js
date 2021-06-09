const {exec} = require('child_process');
const redis = require('./redis');


// TODO: we need to integrate vessel node utils ...
const REDIS_PRFIX = 'harvest-state-';

/**
 * @class HarvestWrapper
 * @description wrapper around harvest commands
 */
class HarvestWrapper {

  constructor() {
    this.CLI_NAME = 'harvest';
    this._initialized = false;
  }

  /**
   * @method init
   * @description preform any initialization steps required to run a harvest
   * command. Will mostly run login. This will only run once but can be called 
   * many times.
   * 
   * @returns {Promise}
   */
  async init() {
    if( this._initialized ) return;
    redis.connect();
    await this.exec(this.CLI_NAME+' login');
    this._initialized = true;
  }

  async user(id) {
    let state = await redis.client.get(REDIS_PRFIX+id);
    if( state !== 'queued' ) return false;

    await redis.client.set(REDIS_PRFIX+id, 'running');

    id = id.replace(/@.*/, '');
    let stdio = this.exec(`${this.CLI_NAME} -v user --search="userId=${id}"`);

    await redis.client.del(REDIS_PRFIX+id);
    return stdio;
  }

  exec(cmd) {
    return new Promise((resolve, reject) => {
      exec(cmd, {shell: '/bin/bash', env: process.env}, (error, stdout, stderr) => {
        console.log(error, stdout, stderr);
        if( error ) reject(error);
        else resolve({stdout, stderr});
      });
    });
  }

}

/**
 * @function run
 * @description run a harvest job for a user
 */
module.exports = new HarvestWrapper();