
const express = require('express');
const path = require('path');
const t20x = require('./t420robot/index');


module.exports = (app) => {
  app.get('/api', (req, res) => res.status(200).send({
    message: 'Welcome to the Device API!',
  }));

  let p = path.join(__dirname, t20x.getStaticWWWpath());
  console.log("Static path: " + p);
  
  app.use(express.static(path.join(__dirname, t20x.getStaticWWWpath())));

  app.post('/auth.cgi', t20x.auth);
  app.get('/getinfo.cgi', t20x.getinfo);
  app.get('/reboot.cgi', t20x.reboot);
  app.get('/getauth.cgi', t20x.getauth);

  app.get('/getappcfg.cgi', t20x.getappcfg);

  app.post('/docmd.cgi', t20x.doCommand);

  app.get('/resetappcfg.cgi', t20x.resetappcfg);

  app.get('/getstats.cgi', t20x.getstats);
  
  app.get('/getcommscfg.cgi', t20x.getcommscfg);
  app.get('/resetcommscfg.cgi', t20x.resetcommscfg);

  app.post('/scale.cgi', t20x.scale);


};
