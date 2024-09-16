//-----------------------------------------------------------------------------
// (C) Radical Electronic Systems, info@radicalsystems.co.za
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// General HTML DOM Functions
//-----------------------------------------------------------------------------
var uuid = "loading...";
var statsInterval = null;
var rebootTime;
var rebootTimer
const lib_version = "1.0.4";
const PROXY = "http://10.0.0.1"
const USE_PROXY = false

function getURL(uri) {
	return USE_PROXY ? PROXY + "/" + uri : uri
} 

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
	fetch(getURL('cgi/'+cgi)).then(response => {
		console.log("get response: ", response)
		if (!response.ok) {
			throw new Error(`HTTP error, status = ${response.status}`);
		}
		
		return response.json();
	}).then(data => {
		console.log("data: ", data)
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
	// Note: Custom headers causes OPTIONS request which is not supported by Hiawatha
	// headers.append('Access-Control-Allow-Origin', 'http://localhost:8081');
	// headers.append('Access-Control-Allow-Headers', 'x-requested-with, Content-Type, origin, authorization, accept, client-security-token');
	// headers.append('Access-Control-Allow-Credentials', true);
	// headers.append('Access-Control-Allow-Methods', 'POST, OPTIONS');

	const params = {
		method: 'POST',
		cache: 'no-cache',
		mode: 'cors',
		body: data,
		headers: headers
	}

	fetch(getURL('cgi/'+cgi), params).then(response => {
		console.log("post response: ", response)
		if (!response.ok) {
			throw new Error(`HTTP error, status = ${response.status}`);
		}

		const contentType = response.headers.get('Content-Type');

		if (!contentType || !contentType.includes("application/json")) {
			throw new TypeError(`JSON data expected, got ${contentType}`);
		}
		
		return response.json();
	}).then(data => {
		console.log("data: ", data)
		if("status" in data) {
			callback(data);
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
		console.info(m); //Blue color text with icon
	}
	else if(l == 2) {
		console.log(m); //Black color text with no icon
	}
	else if(l == 3) {
		console.debug(m); //Pure black color text
	}
	else if(l == 4) {
		console.warn(m); //Yellow color text with icon
	}
	else if(l == 5) {
		console.error(m); //Red Color text with icon
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
	layerLogin : ''
}

const LAYER_LOADER = {
	layerHome : loadHome,
	layerApp : loadApp,
	layerContact : loadContact,
	layerAdmin : loadAdmin,
	layerComms : loadComms,
	layerLoading : loadLoading,
	layerLogin : ''
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
function loadComms(evt) {
	layer = 'layerComms';
	loadLoading();
	getData('getcomms.sh', this.setCommsCfgCB);
}

function setNetState (label, s) {
	docGetElById(label + '_ipa').disabled = s;
	docGetElById(label + '_nm').disabled = s;
	docGetElById(label + '_gw').disabled = s;
	docGetElById(label + '_ntp').disabled = s;
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
	sv(label + '_ntp', cfg.ntp);
	sv('net_' + label + '_name', cfg.name);
	
	docGetElById('net_' + label + '_name').innerHTML = "Interface: " + cfg.name;

	if(label == 'wireless') {
		sv(label + '_ssid', cfg.ssid);
		sv(label + '_ap_mac', cfg.apmac);
		sv(label + '_ap_signal', cfg.apsignal + "%");
	}
	
}

function setSerialPort(type, cfg) {
	let brs = docGetElById(type + '_baudSelect_port' + cfg.index);	

	if(brs) {
		while(brs.options.length) {                
			brs.remove(0);
		}
		const bra = cfg.baudrateOptions.split(',');
		const bros = bra.map((br) => {
			const bro = docCreateEl("option");
			bro.text = br;
			bro.value = br;
			return bro;
		})
		bros.forEach((o) => brs.add(o));
		brs.value = cfg.baudrate;
	}

	const el = docGetElById(type + '_name_port' + cfg.index);
	if(el) {
		el.innerHTML = "Port: " + cfg.name;
		scb(type + '_enable_port' + cfg.index, cfg.enabled);
	}
}

//HTML Link
function resetCommsCfg () {

	layer = 'layerComms'
	getData('resetcommscfg.sh', () => {
			alertInfo('Success: Communications settings reset to default values');
			loadComms();
		}
	);

}

// Get Comms callback
function setCommsCfgCB(data) {
	showMenuLayer('layerComms');
	hideLayerByID('layerComms_wired')
	hideLayerByID('layerComms_wireless')
	
	if(data.status=="OK") {
		if("commsConfig" in data) {
			const cfc = data["commsConfig"];			
			if("networkConfig" in cfc) {
				const ncf = cfc["networkConfig"]; // this is an array	
				ncf.forEach((n) => setNetwork(n.type, n));
			}
				
			if("serialConfig" in cfc) {
				const sca = cfc["serialConfig"]; // this is an array	
				sca.forEach((p) => setSerialPort(p.type, p));				
			}
		}
	}
	else {
		log(0,'Failed to get communications configuration!\nResult:' + data.status);
	}
}


function getWiredSettings() {
	return 'enabled=true' + 
		'&dhcp=' + (ov('wired_dhcp') === 'true' ? 'auto' : 'manual') +
		'&ipaddr=' + ov('wired_ipa') + 
		'&netmask=' + ov('wired_nm') +
		'&gateway=' + ov('wired_gw') +
		'&dns=' +  ov('wired_dns') +
		'&ntp=' + ov('wired_ntp')
}

function getWirelessSettings() {
	return 'enabled=true' + 
		'&dhcp=' + (ov('wireless_dhcp') === 'true' ? 'auto' : 'manual') +
		'&ipaddr=' + ov('wireless_ipa') + 
		'&netmask=' + ov('wireless_nm') +
		'&gateway=' + ov('wireless_gw') +
		'&dns=' +  ov('wireless_dns') +
		'&ntp=' + ov('wireless_ntp') +
		'&ssid=' + ov('wireless_ssid') +
		'&passkey=' + ov('wireless_passkey')
}

function getSerialSettings() {
	const brs0 = docGetElById('RS232_baudSelect_port0').value;
	const brs1 = docGetElById('RS232_baudSelect_port1').value;
	const en0 = ov('RS232_enable_port0');
	const en1 = ov('RS232_enable_port1');
	
	return `serial_enabled_0=${en0}&serial_enabled_1=${en1}&serial_baudrate_0=${brs0}&serial_baudrate_1=${brs1}`;		
}

function saveCommsCfg() {

	const wiredCfg = getWiredSettings();
	const wiredlessCfg = getWirelessSettings();
	const serialCfg = getSerialSettings();

	setData('setethernet.sh', wiredCfg, (data) => {

		if(data.status === 'OK') {
			
			setData('setwifi.sh', wiredlessCfg, (data) => {

					if(data.status === 'OK') {

						setData('setserial.sh', serialCfg, (data) => {
							
							if(data.status === 'OK') {
								alertInfo('Success: Communications Settings Saved!');
							}
							else {
								log(0,'Error while saving serial settings!<br/>Result: ' + ((typeof data.message !== 'undefined') ? data.message : "Unknown error occured!"));			
							}
						
						});

						
					}
					else {
						log(0,'Error while saving wireless settings!<br/>Result: ' + ((typeof data.message !== 'undefined') ? data.message : "Unknown error occured!"));			
					}

				});
		}
		else {
			log(0,'Error while saving ethernet settings!<br/>Result: ' + ((typeof data.message !== 'undefined') ? data.message : "Unknown error occured!"));
		}

	})
	
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
	getData('getinfo.sh', this.setFormHomeCB);
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
// Authentification Page TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadAuth() {
	showMenuLayer('layerLogin');
	docGetElById('login-password').value = "";
}

function appLogin() {

	setData('auth.sh', {password: ov('login-password')}, (data) => {
			if(data.status == "AUTH") {
				loadActiveMenuLayer();
			}
			else {
				alertInfo('Failed to login, please enter correct password');
				sv('login-password', '');
				loadAuth();
			}		
		}
	);	

	return false;
}

//-----------------------------------------------------------------------------
//Administration Page/Layer Functions
//-----------------------------------------------------------------------------
function loadAdmin(evt) {
	layer = 'layerAdmin';
	showMenuLayer(layer);
}

function saveAdmin() {
	const cfg = {
		setAdminConfig : {
			password : ov('current-password'),
			newPassword: ov('new-password')
		}
	}

	setData('docmd.sh', cfg, (data) => {
		alertInfo('Success: New password saved!');
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
	getData('getapp.sh', this.setFormAppCB);
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
		
	}
}

function saveAppCfg() {

	const payload = 
	'serverUrl=' + ov('app_url') +
	'&engine=' + ov('app_engine') +
	'&scale=' + ov('app_scale') +
	'&protocol=' + ov('app_proto') +
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
