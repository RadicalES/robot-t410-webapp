class Network {

	constructor(mac, dhcp, ipaddress, netmask, gateway, dns, ntp) {
		this.MAC = mac;
		this.DHCP = dhcp;
		this.IpAddress = ipaddress;
		this.SubNet = netmask;
		this.Gateway = gateway;
		this.DnsServer = dns;
		this.NtpServer = ntp;
	}

	  // cfg : JSON object
	setConfig(cfg) {
	    this.DHCP = cfg.dhcp;
	    this.IpAddress = cfg.ipaddress;
	    this.SubNet = cfg.subnet;
	    this.Gateway = cfg.gateway;
	    this.DnsServer = cfg.dns;
	    this.NtpServer = cfg.ntp;
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
			type: "wired",
			name: "LAN0",
			macAddress: this.MAC,
			dhcp: this.DHCP.toString(),
			ipAddress: this.IpAddress,
			netmask: this.SubNet,
			gateway: this.Gateway,
			ntp: this.NtpServer,
			dns: this.DnsServer,
		}
  		
    }

  }

  module.exports = Network;
