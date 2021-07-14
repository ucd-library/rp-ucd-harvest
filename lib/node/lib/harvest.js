const {exec, spawn} = require('child_process');
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
    // await this.exec(this.CLI_NAME+' login');
    // await this.exec('http --check-status --session=elements --auth=ucd:4eKuwAhZLG --print=h https://oapolicy.universityofcalifornia.edu:8002/elements-secure-api/v5.5/groups');
    this._initialized = true;
  }

  async user(id) {
    let state = await redis.client.get(REDIS_PRFIX+id);
    if( state !== 'queued' ) return false;

    await redis.client.set(REDIS_PRFIX+id, 'running');

    id = id.replace(/@.*/, '');
    let stdio = this.exec(`${__dirname}/harvest-user.sh`, [id]);

    await redis.client.del(REDIS_PRFIX+id);
    return stdio;
  }

  exec(cmd, args) {
    console.log('running command: ', cmd, args);
    // return new Promise((resolve, reject) => {
    //   let cp = exec(cmd, {shell: '/bin/bash', env: process.env}, (error, stdout, stderr) => {
    //     console.log(error, stdout, stderr);
    //     if( error ) reject(error);
    //     else resolve({stdout, stderr});
    //   });
      
    //   // stdin seems to be open and waiting when a child process....
    //   cp.stdin.write('jrmerz');
    //   cp.stdin.end();
    // });
    let stderr = '';
    let stdout = '';

    return new Promise((resolve, reject) => {
      const ls = spawn(cmd, args, 
        {
          detached: true, 
          stdio: [ 'ignore', 'pipe', 'pipe' ]
        });
      
      ls.stdout.on('data', data => stdout += data);
      ls.stderr.on('data', data => stderr += data);
      
      ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        console.log({stdout, stderr});
        resolve({stdout, stderr});
      });
    });
  }

}

/**
 * @function run
 * @description run a harvest job for a user
 */
module.exports = new HarvestWrapper();