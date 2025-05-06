class SerialPort {

  constructor(type, name, baudrate, stopbits, parity, index) {
    this.Enabled = true;
    this.Type = type;
    this.Name = name;
    this.Baudrate = baudrate;
    this.StopBits = stopbits;
    this.Parity = parity;
    this.Index = index;
    this.Protocol = "16";
  }

  setConfig(cfg) {
 
    if((this.Type == "RS232") || (this.Type == "EXTBUS")) {
      this.Baudrate = cfg.baudrate;
      this.StopBits = cfg.stopbits;
      this.Parity = cfg.parity;
    }

    this.Enabled = (cfg.enabled == "true");
  }
  
  resetConfig() {
	  if((this.Type == "RS232") || (this.Type == "EXTBUS")) {
		  this.Baudrate = "9600";
		  this.StopBits = "1";
		  this.Parity = "NONE";
	  }
	  this.Protocol = "NONE";
	  this.Enabled = false;
  }

  getConfig() {
    return {
      type: this.Type,
      name: this.Name,
      baudrateOptions: "1200,2400,4800,9600,19200,38400,57600,115200",
      baudrate: this.Baudrate,
      stopbitsOptions: "1,2",
      parityOptions: "ODD,EVEN,NONE",
      parity: this.Parity,
      enabled: this.Enabled,
      index: this.Index,
    }
	  
  }

}
module.exports = SerialPort;
