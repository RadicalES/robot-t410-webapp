class PalPi {

	constructor(index, enabled, localPort, remoteURL, printMode) {
		this.index = index;
		this.enabled = enabled;
		this.enabledReset = enabled;
		this.localPort = localPort;
        this.localPortReset = localPort;
		this.remoteURL = remoteURL;
        this.remoteURLReset = remoteURL;
		this.printMode = printMode;
        this.printModeReset = printMode;
	}

	  // cfg : JSON object
	setConfig(cfg) {
		const cfgs = cfg.split("&") 
    	let cfgObj = {}
    	for(let c in cfgs) {
      		const s = cfgs[c].split("=")
      		cfgObj[s[0]] = s[1]
    	}
		console.log("PALPI CFG = ", cfgObj)
	    this.enabled = cfgObj.enabled;
		this.localPort = cfgObj.localPort;
		this.remoteURL = cfgObj.remoteURL;
		this.printMode = cfgObj.printMode;
	}
	
	resetConfig() {
		this.enabled = this.enabledReset;
		this.localPort = this.localPortReset;
		this.remoteURL = this.remoteURLReset;
		this.printMode = this.printModeReset;
	}
  	
  	getConfig() {
		return {
			index: this.index,
			enabled: this.enabled,
			localPort: this.localPort,
			remoteURL: this.remoteURL,
			printMode: this.printMode
		}
  		
    }

  }

  module.exports = PalPi;