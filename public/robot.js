//-----------------------------------------------------------------------------
// (C) Radical Electronic Systems, info@radsys.io
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// General HTML DOM Functions
//-----------------------------------------------------------------------------
var uuid = "loading...";
var layer = '';
var statsInterval = null;
var rebootTime;
var rebootTimer
const lib_version = "2.0.2";

// Element selectors short hand
// short hand for getting element by Id in the DOM
function docGetElById(id) {
	return document.getElementById(id);
}

// short hand for getting elements by name in the DOM
function docGetElsByName(nm) {
	return document.getElementsByName(nm);
}

// short hand for getting elements by class name in the DOM
function docGetElsByClsName(nm) {
	return document.getElementsByClassName(nm);
}

function docCreateEl(type) {
	return document.createElement(type);
}

function getData(cgi, callback) {
	const params = {
		cache: 'no-cache',
		credentials: 'same-origin',
		headers: {
			'Content-Type': 'application/json',
            // 'Access-Control-Allow-Origin': '*',
            // 'Access-Control-Allow-Credentials':true,
            // 'Access-Control-Allow-Methods':'GET'
		}
	}
	fetch('/cgi/' + cgi).then(response => {
		if (!response.ok) {
			throw new Error(`HTTP error, status = ${response.status}`);
		}
		
		return response.json();
	}).then(data => {
		if("status" in data) {
			if(data.status == "OK") {
				callback(data);
			}
			else {
				log(0,'Error: Unknown status!<br/>Result: ' + data.status);
			}
		}
		else {
			log(0,'Error: data error!<br/>Result: ' + data.message);;
		}
	}).catch(error => {
		log(0,'Error: Unknown status!<br/>Result: ' + error.message);
	})
}

function setData(cgi, data, callback) {
	const headers = new Headers();
	headers.append('Content-Type', 'text/plain');

	const params = {
		method: 'POST',
		cache: 'no-cache',
		mode: 'cors',
		body: data,
		headers: headers
	}

	fetch('/cgi/' + cgi, params).then(response => {
		if (!response.ok) {
			throw new Error(`HTTP error, status = ${response.status}`);
		}

		const contentType = response.headers.get('Content-Type');

		if (!contentType || !contentType.includes("application/json")) {
			throw new TypeError(`JSON data expected, got ${contentType}`);
		}
		
		return response.json();
	}).then(data => {
		if("status" in data) {
			if(data.status == "OK") {
				callback(data);
			}
			else {
				log(0, 'Error: ' + (data.message || data.status));
			}
		}
		else {
			log(0,'Error: data error!<br/>Result: ' + data.message);;
		}
	}).catch(error => {
		log(0,'Error: Unknown status!<br/>Result: ' + error.message);
	})
}

// Startup
window.onload = function() {
	uuid = uuidv4();
	layer = '';
	docGetElById("guiversion").innerHTML += "(lib:" + lib_version + ")";
	loadLoading();
	loadHome();
	//startStatsInterval();
}

// General error handler
// l : level
// 0 = alert box
// 1 = info log
// 2 = warning
// 3 = error
// m : message
function log(l,m) {
	if(l == 0) {
		console.log(m);
		alertError(m);
	}
	else if(l == 1) {
		console.info(m);
	}
	else if(l == 2) {
		console.log(m);
	}
	else if(l == 3) {
		//console.debug(m);
	}
	else if(l == 4) {
		console.warn(m);
	}
	else if(l == 5) {
		console.error(m);
	}
}

// Fetch a value of a HTML Element, find by DOM ID
function ov(id) {
	let o = docGetElById(id);
	if(o) {
		if(o.type == "checkbox") {
			//return (obj.checked) ? obj.value : 0;
			return (o.checked) ? "true" : "false";
		}
		else if(o.type == "radio") {
			return ovrb (id);
		}
		else {
			return docGetElById(id).value;
		}
	}
	else {
		log(4,"Element undefined: " + id);
		return "undefined";
	}
}

// Fetch HTML Radio Buttons Group check buttons value
function ovrb(nm) {
	const oe = docGetElsByName(nm);
	for(var o of oe) {
		if(o.checked) return o.value;
	}	
}

// Check a HTML Radio Button from a group by name with a specific value
function srb(id, value) {
	const oe = docGetElsByName(id);
	if(oe) {
		for(var o of oe) {
			if(o.value == value) {
				o.checked = true;
			}
		}
	}
	else {
		log(4,"Element undefined: " + id);
	}
}

// Set a check box, find by HTML DOM ID
function scb(id, value) {
	let e = docGetElById(id);
	if(e) {
		if(e.type=="checkbox") {
			if(value==1 || value=="TRUE" || value=="true" || value=='auto') {
				e.checked  = true;
			}
			else {
				e.checked  = false;
			}
		}
		else {
			log(4,"sb type error: : " + id);
		}
	}
	else {
		log(4,"sb undefined error: " + id);
	}
}

// Set a value of a HTML element with a specific ID
function sv(id, vl) {
	let o = docGetElById(id);
	if(o) {
		if(o.type == "checkbox") {
			scb(id, vl);
		}
		else if(o.type == "radio") {
			 srb(id, vl);
		}
		else if(o.type == "select") {
			 sd(id, vk);
		}
		else {
			o.value = vl;
		}
	}
	else {
		log(4,"sv error: undefined element: " + id);
	}
}

// Set value of select input, find by HTML DOM ID
function ssi(id, value) {
	const sl = docGetElById(id);
	if(sl) {
		for(var s of sl.options) {
			if(s.value === value) {
				s.selected = true;
				break;
			}
		}
	}
	else {
		log(4,"Select undefined: " + id);
	}
}

function getLibVersion() {
	return lib_version;
}

const LAYER_MENUS = {
	layerHome : 'menuHome',
	layerApp : 'menuApp',
	layerContact : 'menuContact',
	layerAdmin : 'menuAdmin',
	layerComms : 'menuComms',
}

const LAYER_LOADER = {
	layerHome : loadHome,
	layerApp : loadApp,
	layerContact : loadContact,
	layerAdmin : loadAdmin,
	layerComms : loadComms,
	layerLoading : loadLoading,
}


//-----------------------------------------------------------------------------
// HTML Layer Control
//-----------------------------------------------------------------------------
function hidmenu() {
	const x = docGetElById("navhid");
	if (x.className.indexOf('w3-show') == -1) {
		x.classList.add('w3-show');
	} else { 
		x.classList.remove('w3-show');
	}
}

function loadLayerHTML(layerName, callback) {
	const layerContainer = docGetElById('layerContainer');

	// Check if layer already exists
	if (docGetElById(layerName)) {
		if (callback) callback();
		return;
	}

	// Load the layer HTML file. Force no-cache so fragment edits take effect on
	// the next load - otherwise the browser serves a stale layer and UI changes
	// appear to "not deploy" even after the device file is updated.
	fetch('layers/' + layerName + '.html', { cache: 'no-cache' })
		.then(response => {
			if (!response.ok) {
				throw new Error(`Failed to load ${layerName}.html`);
			}
			return response.text();
		})
		.then(html => {
			// Create a temporary container
			const temp = document.createElement('div');
			temp.innerHTML = html;

			// Append hidden to layer container (shown after data loads)
			var el = temp.firstElementChild;
			el.style.display = 'none';
			layerContainer.appendChild(el);

			if (callback) callback();
		})
		.catch(error => {
			log(0, 'Error loading layer: ' + error.message);
		});
}

function hidMnuLyrs() {
	const lrs = docGetElsByClsName('layer');
	for(var lr of lrs) {
		lr.style.display = 'none';
	}
	const n = docGetElById('navhdr');
	const l = n.querySelectorAll('button')
	for(var i of l) {
		i.classList.remove('active');
	}
}

function showMenuLayer(ln) {
	hidMnuLyrs();
	docGetElById(ln).style.display = 'block';
	const l = LAYER_MENUS[ln];
	if(l) {
		docGetElById(LAYER_MENUS[ln]).classList.add('active');
	}
}

function loadActiveMenuLayer() {
	// fix this pointer
	LAYER_LOADER[layer].call(this);
}

function showLayerByID(ln) {
	docGetElById(ln).style.display = 'block';
}

function hideLayerByID(ln) {
	docGetElById(ln).style.display = 'none';
}

function alertInfo(msg) {
	const i = docGetElById("infoMsg");
	i.innerHTML = msg;
	showLayerByID("layerInfoModal");
}

function alertError(msg) {
	const i = docGetElById("errorMsg");
	i.innerHTML = msg;
	showLayerByID("layerErrModal");
}

function setUptime(val) {
	let ut = parseInt(val);
	ut = Math.round(ut / 60.0);
	sv('uptime', ut.toString() + " min");
}

//-----------------------------------------------------------------------------
// Loading TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadLoading(evt) {
	layer = 'layerLoading';
	showMenuLayer('layerLoading');
}

//-----------------------------------------------------------------------------
// Communications TAB/Layer Functions
//-----------------------------------------------------------------------------
let scadaTimer = null;
function loadComms(evt) {
	loadLoading();
	loadLayerHTML('layerComms', () => {
		// After loadLoading(), not before: it sets `layer` to 'layerLoading',
		// so assigning first left the timer below cancelling itself five
		// seconds later, and the card showing whatever was true at page load.
		layer = 'layerComms';
		getData('getcomms.sh', setCommsCfgCB);
		refreshScada();
		if (scadaTimer) clearInterval(scadaTimer);
		scadaTimer = setInterval(() => {
			if (layer !== 'layerComms') { clearInterval(scadaTimer); scadaTimer = null; return; }
			refreshScada();
		}, 5000);
	});
}

function refreshScada() {
	getData('getscada.sh', setScadaCB);
}

// SCADA connection status callback (from getscada.sh)
function setScadaCB(data) {
	if (!data || data.status != "OK" || !("scada" in data)) return;
	const s = data.scada;
	let color, text;
	// Switched off and crashed are different things to be told.
	if (!s.running && s.enabled === false) { color = '#9e9e9e'; text = 'Service disabled'; }
	else if (!s.running) { color = '#9e9e9e'; text = 'Service not running'; }
	else if (s.state == 'ONLINE' && s.healthy) { color = '#4CAF50'; text = 'Connected'; }
	else if (s.state == 'ONLINE') { color = '#ff9800'; text = 'Connection lost'; }
	else if (s.state == 'UNPROVISIONED') { color = '#ff9800'; text = 'Reachable - not provisioned'; }
	else { color = '#f44336'; text = 'Offline'; }
	const dot = docGetElById('scada_dot');
	if (dot) dot.style.backgroundColor = color;
	const st = docGetElById('scada_state');
	if (st) st.innerHTML = text;
	const su = docGetElById('scada_url');
	if (su) su.textContent = s.serverURL || '—';
	const stn = docGetElById('scada_station');
	if (stn) stn.innerHTML = s.station || '&mdash;';
	const lc = docGetElById('scada_last');
	if (lc) lc.innerHTML = (s.lastContact >= 0) ? (s.lastContact + 's ago') : 'never';
}

// Interface name per section, filled in from getcomms.sh.
var netIface = {};

function setNetState (label, s) {
	docGetElById(label + '_ipa').disabled = s;
	docGetElById(label + '_nm').disabled = s;
	docGetElById(label + '_gw').disabled = s;
	docGetElById(label + '_dns').disabled = s;
}

function setNetwork(label, cfg) {
	showLayerByID('layerComms_' + label)
	scb(label + '_dhcp', cfg.dhcp);
	setNetState(label, cfg.dhcp == "auto");
	sv(label + '_mac', cfg.macAddress);
	sv(label + '_ipa', cfg.ipAddress);
	sv(label + '_nm', cfg.netmask);
	sv(label + '_gw', cfg.gateway);
	sv(label + '_dns', cfg.dns);
	sv('net_' + label + '_name', cfg.name);
	
	docGetElById('net_' + label + '_name').innerHTML = "Interface: " + cfg.name;

	// Which interface these settings belong to. The save posts this rather
	// than assuming eth0, and it doubles as the record of which sections were
	// rendered — a save must not post settings for a section nobody saw.
	netIface[label] = cfg.iface || 'eth0';
}

// The card reader, the scanner and the scale are the same shape: a device on a
// serial port, bridged onto a websocket, started by systemd. One renderer, so
// a fix to how a service is shown is a fix to all three.
//
// The scale is the exception in two places, and only two: it has no output
// format (wsScale sends structured readings) and no foreign-connections
// choice.
function setWsService(label, cfg) {
	showLayerByID('layerComms_' + label)
	scb(label + '_enabled', cfg.enabled);
	scb(label + '_foreign_connect', cfg.foreignConnect);
	sv(label + '_server_port', cfg.serverPort)
	sv(label + '_output_format', cfg.outputFormat)

	// "Enabled" is systemd's is-enabled — whether it starts on boot. Whether
	// it is running right now is a separate answer, and worth showing: a
	// reader that is enabled but stopped, or running but disabled, is exactly
	// the state that looks fine until the terminal is power-cycled.
	const state = docGetElById(label + '_state');
	if (state) {
		const configured = String(cfg.configured) !== 'FALSE';
		const running = String(cfg.running) === 'TRUE' || cfg.running === true;
		if (!configured) {
			// Not a fault: this terminal has never been given one. Saying so
			// is what tells an operator the section is an offer, not a
			// reading.
			state.textContent = 'not set up';
			state.className = 'svc-state';
		} else {
			state.textContent = running ? 'running' : 'stopped';
			state.className = 'svc-state ' + (running ? 'running' : 'stopped');
		}
	}

	// Which serial port it is on, filled from the device's own list of where
	// that service's hardware may be.
	loadSerialPorts(label, cfg.serialPort);

	if (label === 'scale') setScaleModel(cfg);
}

// Which indicator the scale is.
//
// Always settable, even while a SCADA server is naming one. Two reasons: a
// terminal is set up before it is enrolled, and one that has been enrolled can
// be taken away and run standalone — and on that day the protocol it falls
// back to is whatever was chosen here. Hiding the choice while a server is
// present would mean the fallback could only ever be set from a shell.
//
// Precedence is stated rather than enforced by hiding: wsScale reads the
// server's setup after the local file, so the server's value is what runs
// while there is one.
function setScaleModel(cfg) {
	const sel = docGetElById('scale_model');
	const hint = docGetElById('scale_hint');
	if (!sel) return;

	sel.innerHTML = '';
	// An empty first entry, because "no scale chosen" is a real state on a
	// terminal that has not been told which one is on the bench.
	const none = document.createElement('option');
	none.value = '';
	none.textContent = '— none —';
	sel.appendChild(none);
	(cfg.protocols || []).forEach((name) => {
		const o = document.createElement('option');
		o.value = name;
		o.textContent = name;
		if (name === cfg.localModel) o.selected = true;
		sel.appendChild(o);
	});

	if (!hint) return;
	if (cfg.serverModel) {
		hint.textContent = 'The SCADA server specifies ' + cfg.serverModel +
			', which is what runs while this terminal is enrolled. The protocol above' +
			' is used when it runs standalone. Units and weight limits come from the server.';
	} else {
		hint.textContent = 'No SCADA server: the protocol above is what runs, and' +
			' weight limits do not apply.';
	}
}

// The port list for one service. Rendered as a dropdown, or as text when the
// terminal reports the port as fixed — the card reader is soldered to ttyS0,
// and a dropdown with one item in it reads as though there were others to
// find.
function loadSerialPorts(label, current) {
	const sel = docGetElById(label + '_serial_port');
	const fixed = docGetElById(label + '_serial_port_fixed');
	if (!sel && !fixed) return;

	getData('getserialports.sh?service=' + label, (data) => {
		const ports = (data && data.serialPorts) || [];
		const isFixed = String(data && data.fixed) === 'true';

		// The terminal's answer, not a count: one port today does not make a
		// port fixed — a scanner is the only USB device plugged in until
		// somebody plugs in a second one.
		if (isFixed) {
			const only = ports.length ? ports[0] : null;
			let text = current || '—';
			if (only) {
				text = only.device + (only.present === false ? '  — not present' : '');
			}
			if (fixed) { fixed.textContent = text; fixed.style.display = ''; }
			if (sel) sel.style.display = 'none';
			return;
		}

		if (fixed) fixed.style.display = 'none';
		if (!sel) return;
		sel.style.display = '';
		sel.innerHTML = '';
		ports.forEach((p) => {
			const o = document.createElement('option');
			o.value = p.device;
			// A port another service already holds is shown and disabled
			// rather than hidden: "ttyUSB0 — scale" says why it cannot be
			// picked, where a missing entry just looks like absent hardware.
			const claim = p.claimedBy && p.claimedBy !== label ? '  — ' + p.claimedBy : '';
			o.textContent = p.device + (p.label ? '  (' + p.label + ')' : '') + claim;
			o.disabled = !!claim;
			if (p.device === current) o.selected = true;
			sel.appendChild(o);
		});

		// The port it is on now, even if the list no longer offers it — a
		// scanner unplugged since the save must not silently become another
		// device on the next save.
		if (current && !ports.some((p) => p.device === current)) {
			const o = document.createElement('option');
			o.value = current;
			o.textContent = current + '  — not present';
			o.selected = true;
			sel.appendChild(o);
		}
	});
}


//HTML Link
function resetCommsCfg () {

	layer = 'layerComms'
	getData('resetcomms.sh', () => {
			alertInfo('Success: Communications settings reset to default values');
			loadComms();
		}
	);

}

// Get Comms callback
function setCommsCfgCB(data) {
	showMenuLayer('layerComms');
	hideLayerByID('layerComms_wired')
	hideLayerByID('layerComms_cardreader')
	hideLayerByID('layerComms_scanner')
	hideLayerByID('layerComms_scale')
	netIface = {};
	if(data.status=="OK") {
		if("commsConfig" in data) {
			const cfc = data["commsConfig"];			
			if("networkConfig" in cfc) {
				const ncf = cfc["networkConfig"]; // this is an array	
				ncf.forEach((n) => setNetwork(n.type, n));
			}
				
			if("timeConfig" in cfc) {
				sv('system_ntp', cfc["timeConfig"].ntp);
			}

			// Every service this terminal COULD run, whether or not it has
			// been set up.
			//
			// Hiding the unconfigured ones was circular: a scanner has no
			// config until somebody configures it, and this page is where that
			// happens - so a terminal that gained a scanner had no way to add
			// it. An unconfigured service shows as "not set up" and becomes
			// real when it is given a port and enabled.
			const services = {
				cardreader: "cardreaderConfig",
				scanner:    "scannerConfig",
				scale:      "scaleConfig",
			};
			wsServices = [];
			Object.keys(services).forEach((label) => {
				const key = services[label];
				if (!(key in cfc)) return;
				wsServices.push(label);
				setWsService(label, cfc[key]);
			});


		}
	}
	else {
		log(0,'Failed to get communications configuration!\nResult:' + data.status);
	}
}


// Site settings for one interface — address, mask, gateway, DNS.
function getNetSettings(label) {
	return 'iface=' + encodeURIComponent(netIface[label] || '') +
		'&dhcp=' + (ov(label + '_dhcp') === 'true' ? 'auto' : 'manual') +
		'&ipaddr=' + ov(label + '_ipa') +
		'&netmask=' + ov(label + '_nm') +
		'&gateway=' + ov(label + '_gw') +
		'&dns=' + ov(label + '_dns');
}

// Which services this terminal has, filled in from getcomms.sh. It doubles as
// the record of which blocks were rendered — a save must not post settings for
// a service nobody saw.
let wsServices = [];

function getWsServiceSettings(label) {
	const sel = docGetElById(label + '_serial_port');
	// The fixed case sends nothing: an empty serial port tells the helper to
	// keep the one the terminal already has, which is the right answer for a
	// reader soldered to the board.
	const port = sel && sel.style.display !== 'none' ? (sel.value || '') : '';

	return 'service=' + label +
	'&enabled=' + ov(label + '_enabled') +
	'&foreignConnect=' + ov(label + '_foreign_connect') +
	'&serverPort=' + ov(label + '_server_port') +
	'&outputFormat=' + encodeURIComponent(ov(label + '_output_format') || '') +
	'&serialPort=' + encodeURIComponent(port) +
	// Only the scale has one, and only when this terminal is the one deciding.
	(label === 'scale' ? '&scaleModel=' + encodeURIComponent(scaleModelChoice()) : '');
}

function scaleModelChoice() {
	const sel = docGetElById('scale_model');
	return sel ? (sel.value || '') : '';
}

function saveCommsCfg() {

	// One request per interface section that was actually rendered, then the
	// time server, then each websocket service the terminal has.
	const steps = ['wired']
		.filter((label) => netIface[label])
		.map((label) => ['setnwk.sh', getNetSettings(label)]);

	steps.push(['setntp.sh', 'ntp=' + encodeURIComponent(ov('system_ntp'))]);
	wsServices.forEach((label) => {
		steps.push(['setttysocket.sh', getWsServiceSettings(label)]);
	});

	// Sequentially, not in parallel: these all reach NetworkManager, and it
	// serialises its callers anyway.
	const runNext = (i) => {
		if (i >= steps.length) {
			alertInfo('Success: Communications Settings Saved!');
			return;
		}
		setData(steps[i][0], steps[i][1], () => runNext(i + 1));
	};
	runNext(0);

	return false;
}


//-----------------------------------------------------------------------------
// Contact Page TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadContact(evt) {
	showMenuLayer('layerContact');
}

//-----------------------------------------------------------------------------
// Home Page TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadHome(evt) {
	loadLoading();
	loadLayerHTML('layerHome', () => {
		getData('getinfo.sh', setFormHomeCB);
	});
}

// Update UI with fetched data
function setFormHomeCB(data) {
	showMenuLayer('layerHome');
	if("deviceInfo" in data) {
		const id = data['deviceInfo'];
		sv('model', id.model);
		sv('serialno', id.serialno);
		sv('mandate', id.mandate);
		sv('hwrev', id.hwrev);
		sv('firmware', id.firmware);
		sv('kernel', id.kernel);
		sv('macaddress', id.macaddress);
		sv('etherports', id.etherports);
		sv('serial232ports', id.serial232ports);
		sv('serial485ports', id.serial485ports);
		sv('usbslaveports', id.usbslaveports);
		sv('usbhostports', id.usbhostports);
		sv('wlanports', id.wlanports);
		setUptime(id.uptime);
	}
	else {
		sv('model', 'Device Error');
	}
}

//-----------------------------------------------------------------------------
//Administration Page/Layer Functions
//-----------------------------------------------------------------------------
function loadAdmin(evt) {
	layer = 'layerAdmin';
	showMenuLayer(layer);
}

function saveAdmin() {
	const data = "oldPassword=" + encodeURIComponent(ov('current-password'))
		+ "&newPassword=" + encodeURIComponent(ov('new-password'));

	setData('setpasswd.sh', data, (resp) => {
		alert('Password updated. Please login with your new password.');
		window.location.reload();
		}
	);

	return false;
}


//-----------------------------------------------------------------------------
// Application Page/Layer Functions
//-----------------------------------------------------------------------------
function loadApp(evt) {
	layer = 'layerApp';
	loadLoading();
	loadLayerHTML('layerApp', () => {
		getData('getapp.sh', setFormAppCB);
	});
}

function resetAppCfg() {
	layer = 'layerApp'
	getData('resetappcfg.sh', () => {
			alertInfo('Success: Application settings reset to default values');
			loadApp();
		}
	);
}

function setFormAppCB(data) {
	showMenuLayer('layerApp');	
	if("appConfig" in data) {
		const cfg = data["appConfig"];		
		const apes = docGetElById('app_engine');
		const apss = docGetElById('app_scale');
		const apcs = docGetElById('app_proto');
		const apst = docGetElById('app_start');

		if(apst) {
			while(apst.options.length) {                
				apst.remove(0);
			}
			
			const staps = cfg.startapps.split(',');
			for(var i=0; i<staps.length; i++) {
				const aeo = docCreateEl("option");
				const ae = staps[i];
				aeo.text = ae;
				aeo.value = ae;
				apst.add(aeo);
			}
		}
		
		if(apes) {
			while(apes.options.length) {                
				apes.remove(0);
			}
			
			const aea = cfg.engines.split(',');
			for(var i=0; i<aea.length; i++) {
				const aeo = docCreateEl("option");
				const ae = aea[i];
				aeo.text = ae;
				aeo.value = ae;
				apes.add(aeo);
			}
		}

		if(apss) {
			while(apss.options.length) {                
				apss.remove(0);
			}
			
			const asa = cfg.scales.split(',');
			for(var i=0; i<asa.length; i++) {
				const aso = docCreateEl("option");
				const as = asa[i];
				aso.text = as;
				aso.value = as;
				apss.add(aso);
			}
		}

		if(apcs) {
			while(apcs.options.length) {                
				apcs.remove(0);
			}
			
			const aca = cfg.protocols.split(',');
			for(var i=0; i<aca.length; i++) {
				const aco = docCreateEl("option");
				const ac = aca[i];
				aco.text = ac;
				aco.value = ac;
				apcs.add(aco);
			}
		}
		
		sv('app_url', cfg.serverURL);
		sv('app_engine', cfg.engine);
		sv('app_scale', cfg.scale);
		sv('app_proto', cfg.protocol);
		sv('app_tag', cfg.tagName);
		sv('app_start', cfg.startapp);
		
	}
}

function saveAppCfg() {

	const payload = 
	'serverUrl=' + ov('app_url') +
	'&engine=' + ov('app_engine') +
	'&scale=' + ov('app_scale') +
	'&protocol=' + ov('app_proto') +
	'&startApp=' + ov('app_start') +
	'&tagName=' + ov('app_tag');

	setData('setapp.sh', payload, (data) => {
		if (data.status === 'OK') {
			alertInfo('Success: Application Configuration Saved!');
		} else {
			log(0,'Error: Saving Application Configuration!<br/>Result: ' + data.status);
		}
	})

	return false;
}

//-----------------------------------------------------------------------------
// Reboot Robot
//-----------------------------------------------------------------------------
function deviceReboot () {
	getData('restart.sh', (data) => {
			rebootTime = 20;
			fwRebootTimer();
			alertInfo('Success: Device will reboot in ' + rebootTime);
		}
	);
}

// helpers
function getStats()
{
	jx.load('getstats.cgi', 'json', 'get_long', {}, uuid, "").then(
		(d) => {
			if (d.status=='OK') {
				if("statistics" in d) {
					const s = d['statistics'];
					setUptime(s.uptime);
					sv('app_pubMsgs', s.pubMessages);
					sv('app_dropMsgs', s.dropMessages);
				}
			}

			setTimeout(getStats, 2000);
		}, 
		(e) => {
			log(0,'Error while getting statistics!<br/>Result: ' + e.message);
		}
	);
}

function fwRebootTimer() {
	rebootTime--;
	alertInfo('Success: Device will reboot in ' + rebootTime);

	if(rebootTime == 0) {
		clearTimeout(rebootTimer);
		window.location.reload();
	}
	else {
		rebootTimer = setTimeout(fwRebootTimer, 1000);
	}

}

function startStatsInterval()
{
	setTimeout(getStats, 2000);
}

// hasher
function uuidv4() {
  return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
  )
}
