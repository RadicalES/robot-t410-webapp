class CardReader {

	constructor(index, enabled, foreignConnect, serverPort, outputFormat) {
		this.index = index;
		this.enabled = enabled;
		this.enabledReset = enabled;
		this.foreignConnect = foreignConnect;
		this.foreignConnectReset = foreignConnect;
		this.serverPort = serverPort;
		this.serverPortReset = serverPort;
		this.outputFormat = outputFormat;
		this.outputFormatReset = outputFormat;
	}

	  // cfg : JSON object
	setConfig(cfg) {
		const cfgs = cfg.split("&") 
    	let cfgObj = {}
    	for(let c in cfgs) {
      		const s = cfgs[c].split("=")
      		cfgObj[s[0]] = s[1]
    	}
		console.log("CARDREADER CFG = ", cfgObj)
	    this.enabled = cfgObj.enabled;
		this.foreignConnect = cfgObj.foreignConnect;
		this.serverPort = cfgObj.serverPort;
		this.outputFormat = cfgObj.outputFormat;
	}
	
	resetConfig() {
		this.enabled = this.enabledReset;
		this.foreignConnect = this.foreignConnectReset;
		this.serverPort = this.serverPortReset;
		this.outputFormat = this.outputFormatReset;
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
