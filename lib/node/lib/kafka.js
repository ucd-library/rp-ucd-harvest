const {Consumer, Producer, utils} = require('@ucd-lib/node-kafka');
const waitUntil = require('../lib/wait-until');
const harvest = require('./harvest');

const KAFKA_HOST = process.env.KAFKA_HOST || 'kafka';
const KAFKA_PORT = process.env.KAFKA_PORT || '9092';
const KAFKA_GROUP = process.env.KAFKA_GROUP || 'rp-ucd-harvest';
const KAFKA_QUEUED_HARVEST_TOPIC = process.env.KAFKA_QUEUED_HARVEST_TOPIC || 'harvest-user-queued';
const KAFKA_RUNNING_HARVEST_TOPIC = process.env.KAFKA_RUNNING_HARVEST_TOPIC || 'harvest-user-running';

class HarvestKafka {

  async connect() {
    console.log('waiting for kafka');
    await waitUntil(KAFKA_HOST, KAFKA_PORT);

    console.log('kafka online, connecting');
    this.consumer = new Consumer({
      'group.id': KAFKA_GROUP,
      'metadata.broker.list': KAFKA_HOST+':'+KAFKA_PORT,
    },{
      // make sure we read any unread messages
      'auto.offset.reset' : 'earliest'
    });

    this.producer = new Producer({
      'metadata.broker.list': KAFKA_HOST+':'+KAFKA_PORT,
    });

    console.log('Connecting kafka topics');
    await this.producer.connect();
    await this.consumer.connect();

    await this.ensureTopic(KAFKA_QUEUED_HARVEST_TOPIC);
    await this.ensureTopic(KAFKA_RUNNING_HARVEST_TOPIC);

    console.log('Subscribing to topic: '+KAFKA_QUEUED_HARVEST_TOPIC);
    await this.consumer.subscribe([KAFKA_QUEUED_HARVEST_TOPIC]);
    await this.consumer.consume(msg => this.handleStartMessage(msg));
  }

  ensureTopic(topic) {
    console.log('Ensuring kafka topic: '+topic);
    return utils.ensureTopic({
        topic,
        num_partitions: 10,
        replication_factor: 1
      }, 
      {
        'metadata.broker.list': KAFKA_HOST+':'+KAFKA_PORT,
        'log.retention.ms' : 1000 * 60 * 60 * 24 * 7
      }
    );
  }

  sendMessage(msg) {
    return this.producer.produce({
      topic : KAFKA_RUNNING_HARVEST_TOPIC,
      value : msg,
    });
  }

  async handleStartMessage(msg) {
    let payload = JSON.parse(msg.value);
    console.log('Harvesting user: '+payload.user);
    
    await harvest.init();

    this.sendMessage({user: payload.user, status: 'starting'});
    let startTime = Date.now();

    let error = null; 
    let stdio = {};

    try {
      stdio = await harvest.user(payload.user);
    } catch(e) { 
      error = e.message;
    }

    if( stdio ) {
      if( stdio.stdout ) console.log(stdio.stdout);
      if( stdio.stderr ) console.error(stdio.stderr);
    }

    this.sendMessage({
      user: payload.user, 
      status: 'complete', 
      stdio, error,
      time: Date.now() - startTime
    });
  }

}

module.exports = new HarvestKafka();