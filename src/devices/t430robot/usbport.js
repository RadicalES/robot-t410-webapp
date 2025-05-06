class USBPort {

  constructor(name) {
    this.Enabled = "TRUE";
    this.Type = "USB";
    this.Name = name;
    this.Protocol = "0";
  }

  // cfg : JSON object
  setConfig(cfg) {
    console.log("COMMBUS::setConfig: " + JSON.stringify(cfg));
    if((this.Type == "RS232") || (this.Type == "EXTBUS")) {
      this.Baudrate = cfg.baudrate;
      this.StopBits = cfg.stopbits;
      this.Parity = cfg.parity;
    }
    else if(this.Type == "NETSVR") {
      this.Port = cfg.port;
    }
    this.Protocol = cfg.protocol;
    this.Enabled = cfg.enabled;
  }
  
  resetConfig() {
	  if((this.Type == "RS232") || (this.Type == "EXTBUS")) {
		  this.Baudrate = "9600";
		  this.StopBits = "1";
		  this.Parity = "NONE";
	  }
	  else if(this.Type == "NETSVR") {
		  this.Port = "21";
	  }
	  this.Protocol = "NONE";
	  this.Enabled = false;
  }

  //return JSON object
  /*
   * 
   * name: rs232_0
	type: rs232
	buadrates : 9600-115200
	baudrate : 115200
	stopbits : 1
	parity : n
	protocols : XML, MODBUS SLAVE, ...
	protocol : XML
   * 
   * */
  getConfig() {
	  let s = '{\"type\":\"' + this.Type + '\",';
	  s += '\"name\":\"'  + this.Name + '\",';
      s += '\"enabled\":\"'  + this.Enabled + '\",';
      s += '\"protocolOptions\":[{\"name\":\"NONE\",\"code\":\"0\"},{\"name\":\"JSON4RBX\",\"code\":\"15\"}],';
      s += '\"protocol\":\"'  + this.Protocol + '\"}';
    return s;
  }

}
module.exports = USBPort;
