class CardReader {

	constructor(index, enabled, foreignConnect, serverPort, outputFormat) {
		this.index = index;
		this.enabled = enabled;
		this.foreignConnect = foreignConnect;
		this.serverPort = serverPort;
		this.outputFormat = outputFormat;
	}

	  // cfg : JSON object
	setConfig(cfg) {
	    this.enabled = cfg.enabled;
		this.foreignConnect = cfg.foreignConnect;
		this.serverPort = cfg.serverPort;
		this.outputFormat = cfg.outputFormat;
	}
	
	resetConfig() {
		this.DHCP = true;
		this.IpAddress = "192.168.1.20";
		this.SubNet = "255.255.255.0";
		this.Gateway = "192.168.1.1";
		this.DnsServer = "192.168.1.1";
		this.NtpServer = "192.168.1.1";
	}
  	
  	getConfig() {
		return {
			index: this.index,
			enabled: this.enabled,
			foreignConnect: this.foreignConnect,
			serverPort: this.serverPort,
			outputFormat: this.outputFormat
		}
  		
    }

  }

  module.exports = CardReader;
