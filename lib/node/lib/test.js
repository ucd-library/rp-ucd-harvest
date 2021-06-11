const {spawn} = require('child_process');

const p = spawn(`${__dirname}/harvest-user.sh`, ['jrmerz'], 
  {
    detached: true, 
    stdio: [ 'ignore', 'pipe', 'pipe' ]
  });

p.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

p.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

p.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});
