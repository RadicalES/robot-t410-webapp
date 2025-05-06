const t430 = require('./t430robot');
const path = require('path');

module.exports = {
		
  getStaticWWWpath() {
	return path.join("t430robot", t430.getWWWPath());  
  },

  auth(req, res) {
    const m = req.body;
    let r = { status: "NOTAUTH"};
    
    if("password" in m) {
      const p = m["password"];
      const u = req.query.uid;
  		
      if(t430.authenticate(u, p)) {
        r = {
          status: "AUTH",
          uid: u,
          session: t430.getSession()
        }
      }
    }
    
    res.status(200).json(r);
  },

  getinfo(req, res) {
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      console.log("AJAX-Request");
    }
    if (req.headers['x-mac'] != undefined) {
      console.log("AJAX from ROBOT: " + req.headers['x-mac']);
    }

    const rs = {
      status : "OK",
      deviceInfo : {
        model:"Robot-t430-A",
        serialno:"100001",
        mandate:"27-02-2019",
        firmware:"1.0.1",
        hwrev:"1.0",
        macaddress:"AA:BB:CC:00:11:22",
        etherports:"1",
        serial232ports:"0",
        serial485ports:"0",
        usbslaveports:"1",
        scriptsupp:"NO",
        flashsize:"0 MB",
        uptime: t430.getUptime()
      }
    }

    res.status(200).json(rs);
  },


  reboot(req, res) {
    if(t430.isAuthenticated(req.query.uid)) {
      res.status(200).json({status:"OK"});
    }
    else {
      res.status(401).json({status:"NOTAUTH"});
    }
  },

  getauth(req, res) {
    if(t430.isAuthenticated(req.query.uid)) {
      res.status(200).json({status:"AUTH"});
    }
    else {
      res.status(401).json({status:"NOTAUTH"});
    }

  },
  
  getcommscfg(req, res) {
	  if(t430.isAuthenticated(req.query.uid)) {
        const cfg = {
          status: "OK",
          commsConfig : {
            networkConfig : t430.getNetworkConfig(),
            serialConfig : t430.getSerialConfig()
          }
        }

	      res.status(200).json(cfg);
	    }
	    else {
	      res.status(401).json({status:"NOTAUTH"});
	    }
  },
  
  resetcommscfg(req, res) {
	  if(t430.isAuthenticated(req.query.uid)) {
		    t430.resetNetworkConfig();
		    t430.resetSerialConfig();
	      res.status(200).json({status: "OK"});
	    }
	    else {
	      res.status(401).json({status:"NOTAUTH"});
	    }
  },
  
  getappcfg(req, res) {
    if(t430.isAuthenticated(req.query.uid)) {
      const cfg = { 
        status:"OK",
        appConfig: t430.getAppConfig(),
      };
      res.status(200).json(cfg);
    }
    else {
      res.status(401).json({status:"NOTAUTH"});
    }
  },

  doCommand(req, res) {
    if(t430.isAuthenticated(req.query.uid)) {
      const m = req.body;
      if("setAppConfig" in m) {
    	  const cfg = m["setAppConfig"];
        console.log("APP CFG: ", cfg);
    	  t430.setAppConfig(cfg);
        res.status(200).json({status:"OK"})
      }
      else if("setAdminConfig" in m) {
        const cfg = m["setAdminConfig"];
    	  
    	  if(t430.setPassword(cfg.password, cfg.newPassword)) {
    		  res.status(200).json({status:"OK"});
    	  }
    	  else {
    		  res.status(400).json({status:"FAIL", message: "Failed to set pasword"});
    	  }    	 
      }
      else if("setCommsConfig" in m) {
        const cfg = m["setCommsConfig"];

        if("networkConfig" in cfg) {
          let d = cfg["networkConfig"];
          t430.setNetworkConfig(d);
        }
        
        if("serialConfig" in cfg) {
          let d = cfg["serialConfig"];
          t430.setSerialConfig(d);
        }
        
        res.status(200).json({status:"OK"});	   
      }
      else {
        res.status(404).json({status:"FAIL", message:"Command not supported"});
      }

    }
    else {
      res.status(401).json({status:"NOTAUTH"});
    }

  },

  resetappcfg(req, res) {
    if(t430.isAuthenticated(req.query.uid)) {
      res.status(200).json({status:"OK"});
      t430.resetAppConfig();
    }
    else {
      res.status(401).json({status:"NOTAUTH"});
    }
  },

  getstats(req, res) {
    const app = t430.getAppStats();
    const stats = {
      uptime: t430.getUptime(),
      pubMessages : app.pubMessages,
      dropMessages : app.dropMessages
    }

    res.status(200).json({status:"OK", statistics: stats});
  },

  scale(req, res) {
    let m = req.body;
    let ress = {status : "FAIL"}
    console.log("scale: " + JSON.stringify(m));
    
    if("requestSetup" in m) {
      const reqs = m["requestSetup"];
      const mac = reqs.MAC;
      const type = reqs.type;
      const status = reqs.status;
      const clientURL = reqs.clientURL; 

      setup = {
        status : "OK",
        MAC : reqs.MAC,
        lowLimit : "850.0",
        highLimit : "1150",
        units : "Kg",
        name : "WeighBridge 1",
        security : "OPEN",
        message : "SOLAS Scale Ready!",
        serverURL : "http://192.168.60.115:/scale.cgi"
      }

      ress = {
        responseSetup : setup,
      }

    }
    else if("publishScaleWeight" in m) {
      const reqs = m["publishScaleWeight"];
      const mac = reqs.MAC;
      const status = reqs.status;
      const barcode = reqs.barcode;
  
      data = {
        status : "OK",
        MAC : mac,
        LCD1 : "Pallet OK",
        LCD2 : barcode,
        LCD3 : "Success",
        LCD4 : "",
        Green : "true",
        Orange : "false",
        Red : "false"
      }

      ress = {
        responseDisplay : data,
      }
    }

    res.status(200).json(ress);
  },
  
  waitevent(req, res) {
	  t430.waitForEvent(res);    
  },

  init() {}
}
