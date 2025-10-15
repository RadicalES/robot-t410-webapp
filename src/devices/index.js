
const express = require('express');
const path = require('path');
const t430 = require('./t430robot/index');


module.exports = (app) => {
  app.get('/api', (req, res) => res.status(200).send({
    message: 'Welcome to the Device API!',
  }));

  let p = path.join(__dirname, t430.getStaticWWWpath());
  console.log("Static path: " + p);
  
  app.use(express.static(path.join(__dirname, t430.getStaticWWWpath())));

  app.post('/auth.cgi', t430.auth);
  app.get('/cgi/getinfo.sh', t430.getinfo);
  app.get('/reboot.cgi', t430.reboot);
  app.get('/getauth.cgi', t430.getauth);

  app.get('/cgi/getapp.sh', t430.getappcfg);

  app.post('/docmd.cgi', t430.doCommand);

  app.get('/resetappcfg.cgi', t430.resetappcfg);

  app.get('/getstats.cgi', t430.getstats);
  
  app.get('/cgi/getcomms.sh', t430.getcommscfg);
  app.post('/cgi/setcardreader.sh', t430.setcardreadercfg);
  app.get('/cgi/resetcomms.sh', t430.resetcommscfg);

  app.post('/scale.cgi', t430.scale);
  app.post('/cgi/setapp.sh', t430.setappcfg);


};
