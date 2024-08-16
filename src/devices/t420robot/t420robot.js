
const moment = require('moment');
const Network = require('./network');
const Serial = require('./serialport');
const USB = require('./usbport');
const EventEmitter = require('events');

class T202Device {

  constructor() {
	//super();	  
    this.uid = "";
    this.auth = false;
    this.session = "10";
    this.password = "lizard";
    this.logs = [];
    this.startTime = moment();
    this.network = new Network("AA:BB:CC:00:11:22",true,"192.168.1.20","255.255.255.0","192.168.1.1","192.168.1.100","192.168.1.100");
    this.rs232port0 = new Serial("RS232", "Scale", 115200, "1", "EVEN", 0);
    this.rs232port1 = new Serial("RS232", "Scanner", 115200, "1", "EVEN", 1);
    this.usbport = new USB("USB");    
    this.scale = "RICHTER";
    this.scales = "MICRO-A12E,RICHTER";
    this.engines = "DISABLED,SCALE,TERMINAL,BINTIP";
    this.engine = "TERMINAL";
    this.protocols = "ROBOT-API,FARSOFT-SCALE";
    this.protocol = "FARSOFT-SCALE";
    this.serverURL = "http://192.168.60.10/scale.cgi";
    this.tagName = "Scale Robot";
    this.lightsOnTime = 10;
    this.pubMessages = 0;
    this.dropMessages = 0;
    this.bootTime = Date.now();
  }
  
  static getInstance() {
    if( ! (this instanceof T202Device)) {
      return new T202Device();
    }

    return this;
  }

  isAuthenticated(uid) {
    console.log("T202:isAuth uid=" + uid);
    if((uid == this.uid) && (this.auth)) {
      this.pubMessages++; // simulate
      return true;
    }

    this.dropMessages++; // simulate
    return false;
  }
  
  getWWWPath() {
	  return "public";
  }

  getSession() {
    return this.session;
  }

  getUptime() {
    const t = Date.now() - this.bootTime;
    return Math.floor(t/1000);
  }

  authenticate(uid, password) {
    if(this.password == password) {
      this.uid = uid;
      this.auth = true;
      return true;
    }
    return false;
  }

  getAppConfig() {
    return {
      enabled : this.engine,
      engines : this.engines,
      scales : this.scales,
      scale : this.scale,
      protocols : this.protocols,
      protocol : this.protocol,
      lightsOnTime: this.lightsOnTime,
      tagName : this.tagName,
      serverURL : this.serverURL,
      pubMessages : this.pubMessages,
      dropMessages : this.dropMessages
    }
  }

  getAppStats() {
    return {
      pubMessages : this.pubMessages++,
      dropMessages : this.dropMessages
    }
  }

  setAppConfig(cfg) {
    console.log("setAppConfig: " + JSON.stringify(cfg));
    this.scale = cfg.scale;
    this.engine = cfg.enabled;
    this.protocol = cfg.protocol;
    this.serverURL = cfg.serverURL;
    this.tagName = cfg.tagName;
    this.lightsOnTime = cfg.lightsOnTime;
  }
  
  resetAppConfig() {
    this.scale = "MICRO-A12E";
    this.engine = "BINTIP";
    this.protocol = "ROBOT-API";
    this.tagName = "Robot Station";
    this.lightsOnTime = 10;
    this.serverURL = "http://192.168.60.10/scale.cgi";
  }

  getNetworkConfig() {
	  return [ this.network.getConfig() ];
  }
  
  setNetworkConfig(cfga) {
	for(var i=0; i<cfga.length; i++) {
		let c = cfga[i];
		if(c.type == 'wired') {
		  this.network.setConfig(c);
		}
	} 
  }
  
  resetNetworkConfig() {
	  this.network.resetConfig();
  }
  
  setPassword(oldPassword, newPassword) {
	  if(this.password === oldPassword) {
      this.password = newPassword;
      console.log("New password: " + newPassword);
      return true;
    }
    return false;
  }

  getSerialConfig() {
    return [
        this.rs232port0.getConfig(),
        this.rs232port1.getConfig(),
        this.usbport.getConfig()
      ];
  }
  
  resetSerialConfig() {
    this.rs232port0.resetConfig();
    this.rs232port1.resetConfig();
	  this.usbport.resetConfig();
  }
  
  setSerialConfig(cfga) {

    cfga.forEach((c) => {

      if(c.type === 'RS232') {
        const idx = c.index;
        if(idx == 0) {
          this.rs232port0.setConfig(c);
        } 
        else if (idx == 1) {
          this.rs232port1.setConfig(c);
        }
      }

    });

  }

}


const t202 = new T202Device();
module.exports = t202;


