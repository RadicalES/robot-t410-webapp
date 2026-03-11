//-----------------------------------------------------------------------------
// (C) Radical Electronic Systems, info@radicalsystems.co.za
// Robot-T420QT Web Application
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// General HTML DOM Functions
//-----------------------------------------------------------------------------
var uuid = "loading...";
var layer = '';
var rebootTime;
var rebootTimer;
const lib_version = "%%VERSION%%";

function docGetElById(id) {
	return document.getElementById(id);
}

function docGetElsByName(nm) {
	return document.getElementsByName(nm);
}

function docGetElsByClsName(nm) {
	return document.getElementsByClassName(nm);
}

function docCreateEl(type) {
	return document.createElement(type);
}

function getData(cgi, callback) {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', '/cgi/' + cgi, true);
	xhr.onreadystatechange = function() {
		if (xhr.readyState !== 4) return;
		if (xhr.status !== 200) {
			log(0, 'Error: HTTP ' + xhr.status + ' from ' + cgi);
			return;
		}
		try {
			var data = JSON.parse(xhr.responseText);
			if (data.status == "OK") {
				callback(data);
			} else {
				log(0, 'Error: ' + (data.message || data.status));
			}
		} catch(e) {
			log(0, 'Error: JSON parse failed for ' + cgi);
		}
	};
	xhr.send();
}

function setData(cgi, data, callback) {
	var xhr = new XMLHttpRequest();
	xhr.open('POST', '/cgi/' + cgi, true);
	xhr.setRequestHeader('Content-Type', 'text/plain');
	xhr.onreadystatechange = function() {
		if (xhr.readyState !== 4) return;
		if (xhr.status !== 200) {
			log(0, 'Error: HTTP ' + xhr.status + ' from ' + cgi);
			return;
		}
		try {
			var data = JSON.parse(xhr.responseText);
			if (data.status == "OK") {
				callback(data);
			} else {
				log(0, 'Error: ' + (data.message || data.status));
			}
		} catch(e) {
			log(0, 'Error: JSON parse failed for ' + cgi);
		}
	};
	xhr.send(data);
}

// Startup
window.onload = function() {
	uuid = uuidv4();
	layer = '';
	docGetElById("guiversion").innerHTML += " (lib:" + lib_version + ")";
	loadLoading();
	loadHome();
};

function log(l, m) {
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

function ov(id) {
	var o = docGetElById(id);
	if(o) {
		if(o.type == "checkbox") {
			return (o.checked) ? "true" : "false";
		}
		else if(o.type == "radio") {
			return ovrb(id);
		}
		else {
			return docGetElById(id).value;
		}
	}
	else {
		log(4, "Element undefined: " + id);
		return "undefined";
	}
}

function ovrb(nm) {
	var oe = docGetElsByName(nm);
	for(var i = 0; i < oe.length; i++) {
		if(oe[i].checked) return oe[i].value;
	}
}

function srb(id, value) {
	var oe = docGetElsByName(id);
	if(oe) {
		for(var i = 0; i < oe.length; i++) {
			if(oe[i].value == value) {
				oe[i].checked = true;
			}
		}
	}
	else {
		log(4, "Element undefined: " + id);
	}
}

function scb(id, value) {
	var e = docGetElById(id);
	if(e) {
		if(e.type == "checkbox") {
			if(value == 1 || value == "TRUE" || value == "true" || value == 'auto') {
				e.checked = true;
			}
			else {
				e.checked = false;
			}
		}
		else {
			log(4, "sb type error: " + id);
		}
	}
	else {
		log(4, "sb undefined error: " + id);
	}
}

function sv(id, vl) {
	var o = docGetElById(id);
	if(o) {
		if(o.type == "checkbox") {
			scb(id, vl);
		}
		else if(o.type == "radio") {
			srb(id, vl);
		}
		else {
			o.value = vl;
		}
	}
	else {
		log(4, "sv error: undefined element: " + id);
	}
}

function ssi(id, value) {
	var sl = docGetElById(id);
	if(sl) {
		for(var i = 0; i < sl.options.length; i++) {
			if(sl.options[i].value === value) {
				sl.options[i].selected = true;
				break;
			}
		}
	}
	else {
		log(4, "Select undefined: " + id);
	}
}

function getLibVersion() {
	return lib_version;
}

var LAYER_MENUS = {
	layerHome: 'menuHome',
	layerApp: 'menuApp',
	layerComms: 'menuComms',
	layerContact: 'menuContact',
	layerAdmin: 'menuAdmin'
};

var LAYER_LOADER = {
	layerHome: loadHome,
	layerApp: loadApp,
	layerComms: loadComms,
	layerContact: loadContact,
	layerAdmin: loadAdmin,
	layerLoading: loadLoading
};

//-----------------------------------------------------------------------------
// HTML Layer Control
//-----------------------------------------------------------------------------
function hidmenu() {
	var x = docGetElById("navhid");
	if (x.className.indexOf('w3-show') == -1) {
		x.classList.add('w3-show');
	} else {
		x.classList.remove('w3-show');
	}
}

function loadLayerHTML(layerName, callback) {
	var layerContainer = docGetElById('layerContainer');

	if (docGetElById(layerName)) {
		if (callback) callback();
		return;
	}

	var xhr = new XMLHttpRequest();
	xhr.open('GET', 'layers/' + layerName + '.html', true);
	xhr.onreadystatechange = function() {
		if (xhr.readyState !== 4) return;
		if (xhr.status !== 200) {
			log(0, 'Error loading layer: ' + layerName + ' (HTTP ' + xhr.status + ')');
			return;
		}
		var temp = document.createElement('div');
		temp.innerHTML = xhr.responseText;

		var el = temp.firstElementChild;
		el.style.display = 'none';
		layerContainer.appendChild(el);

		if (callback) callback();
	};
	xhr.send();
}

function hidMnuLyrs() {
	var lrs = docGetElsByClsName('layer');
	for(var i = 0; i < lrs.length; i++) {
		lrs[i].style.display = 'none';
	}
	var n = docGetElById('navhdr');
	var btns = n.querySelectorAll('button');
	for(var j = 0; j < btns.length; j++) {
		btns[j].classList.remove('active');
	}
	stopWifiPoll();
}

function showMenuLayer(ln) {
	hidMnuLyrs();
	docGetElById(ln).style.display = 'block';
	var l = LAYER_MENUS[ln];
	if(l) {
		docGetElById(LAYER_MENUS[ln]).classList.add('active');
	}
}

function loadActiveMenuLayer() {
	LAYER_LOADER[layer].call(this);
}

function showLayerByID(ln) {
	docGetElById(ln).style.display = 'block';
}

function hideLayerByID(ln) {
	docGetElById(ln).style.display = 'none';
}

function alertInfo(msg) {
	var i = docGetElById("infoMsg");
	i.innerHTML = msg;
	showLayerByID("layerInfoModal");
}

function alertError(msg) {
	var i = docGetElById("errorMsg");
	i.innerHTML = msg;
	showLayerByID("layerErrModal");
}

//-----------------------------------------------------------------------------
// Loading TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadLoading() {
	layer = 'layerLoading';
	showMenuLayer('layerLoading');
}

//-----------------------------------------------------------------------------
// Home Page TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadHome() {
	loadLoading();
	loadLayerHTML('layerHome', function() {
		getData('getinfo.sh', setFormHomeCB);
	});
}

function setFormHomeCB(data) {
	showMenuLayer('layerHome');
	sv('operatingsystem', data.operatingsystem || '');
	sv('distro', data.distro || '');
	sv('kernel', data.kernel || '');
	sv('macaddress', data.macaddress || '');
	sv('startapp', data.startapp || '');
}

//-----------------------------------------------------------------------------
// Application Page/Layer Functions
// Combines: Window Manager, MQTT Telemetry, TTY WebSocket Server
// All settings stored in /etc/formfactor/appconfig
//-----------------------------------------------------------------------------
function loadApp() {
	layer = 'layerApp';
	loadLoading();
	loadLayerHTML('layerApp', function() {
		getData('getapp.sh', setFormAppCB);
	});
}

function setFormAppCB(data) {
	showMenuLayer('layerApp');

	// Window Manager
	sv('app_url', data.loadUrl || '');
	ssi('app_layout', data.layout || 'portrait');

	// Serial WebSocket Server
	scb('serws_enabled', data.serwsEnabled);
	scb('serws_foreign', data.serwsForeign);
	sv('serws_sport', data.serwsSport || '');
	sv('serws_wport', data.serwsWport || '');
	ssi('serws_baud', String(data.serwsBaud || '9600'));
}

function saveAppCfg() {
	var payload =
		'loadUrl=' + ov('app_url') +
		'&layout=' + ov('app_layout') +
		'&serwsEnabled=' + (ov('serws_enabled') === 'true' ? 'TRUE' : 'FALSE') +
		'&serwsSport=' + ov('serws_sport') +
		'&serwsWport=' + ov('serws_wport') +
		'&serwsForeign=' + (ov('serws_foreign') === 'true' ? 'TRUE' : 'FALSE') +
		'&serwsBaud=' + ov('serws_baud');

	setData('setapp.sh', payload, function(data) {
		if (data.status === 'OK') {
			alertInfo('Success: Application Configuration Saved!');
		} else {
			log(0, 'Error: Saving Application Configuration!<br/>Result: ' + data.status);
		}
	});

	return false;
}

function resetAppCfg() {
	layer = 'layerApp';
	getData('resetappcfg.sh', function() {
		alertInfo('Success: Application settings reset to default values');
		loadApp();
	});
}

//-----------------------------------------------------------------------------
// Communications TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadComms() {
	layer = 'layerComms';
	loadLoading();
	loadLayerHTML('layerComms', function() {
		getData('getlan.sh', function(data) {
			showMenuLayer('layerComms');
			setNetwork('wired', data);
		});
		getData('getwifi.sh', function(data) {
			setNetwork('wireless', data);
		});
	});
}

function switchCommsTab(tab) {
	var tabs = document.querySelectorAll('.comms-tab');
	var panels = document.querySelectorAll('.comms-panel');
	for (var i = 0; i < tabs.length; i++) {
		tabs[i].classList.remove('active');
		panels[i].style.display = 'none';
	}
	if (tab === 'wired') {
		docGetElById('tabLAN').classList.add('active');
		docGetElById('layerComms_wired').style.display = 'block';
	} else {
		docGetElById('tabWiFi').classList.add('active');
		docGetElById('layerComms_wireless').style.display = 'block';
		fetchWifiData();
	}
}

function setNetState(label, s) {
	docGetElById(label + '_ipa').disabled = s;
	docGetElById(label + '_nm').disabled = s;
	docGetElById(label + '_gw').disabled = s;
	docGetElById(label + '_ntp').disabled = s;
	docGetElById(label + '_dns').disabled = s;
}

function setNetwork(label, cfg) {
	scb(label + '_dhcp', cfg.dhcp);
	setNetState(label, cfg.dhcp == "auto");
	sv(label + '_mac', cfg.macAddress);
	sv(label + '_ipa', cfg.ipAddress);
	sv(label + '_nm', cfg.netmask);
	sv(label + '_gw', cfg.gateway);
	sv(label + '_dns', cfg.dns);
	sv(label + '_ntp', cfg.ntp);

	if(label == 'wireless') {
		sv(label + '_ssid', cfg.ssid);
	}
}

function scanWifi() {
	var btn = docGetElById('btnScanWifi');
	var results = docGetElById('wifiScanResults');
	btn.disabled = true;
	btn.textContent = '...';
	results.style.display = 'none';
	results.innerHTML = '';

	getData('scanwifi.sh', function(data) {
		btn.disabled = false;
		btn.textContent = 'Scan';

		var aps = data.accessPoints || [];
		if (aps.length === 0) {
			results.innerHTML = '<div class="ap-empty">No networks found</div>';
			results.style.display = 'block';
			return;
		}

		// Sort by signal strength (strongest first)
		aps.sort(function(a, b) {
			return parseFloat(b.signal) - parseFloat(a.signal);
		});

		// Deduplicate by SSID, keep strongest
		var seen = {};
		var unique = [];
		for (var i = 0; i < aps.length; i++) {
			if (aps[i].ssid && !seen[aps[i].ssid]) {
				seen[aps[i].ssid] = true;
				unique.push(aps[i]);
			}
		}

		var html = '<div class="ap-list">';
		for (var j = 0; j < unique.length; j++) {
			var ap = unique[j];
			var sig = parseFloat(ap.signal);
			var bars = sig > -50 ? 3 : (sig > -70 ? 2 : 1);
			var barClass = bars === 3 ? 'good' : (bars === 2 ? 'fair' : 'poor');
			html += '<div class="ap-item" onclick="selectAP(\'' + ap.ssid.replace(/'/g, "\\'") + '\')">';
			html += '<span class="ap-name">' + ap.ssid + '</span>';
			html += '<span class="ap-signal ' + barClass + '">' + ap.signal + ' dBm</span>';
			html += '</div>';
		}
		html += '</div>';
		results.innerHTML = html;
		results.style.display = 'block';
	});
}

function selectAP(ssid) {
	sv('wireless_ssid', ssid);
	docGetElById('wifiScanResults').style.display = 'none';
	docGetElById('wireless_passkey').focus();
}

var wifiPollTimer = null;

function fetchWifiData() {
	stopWifiPoll();
	pollWifiData();
	wifiPollTimer = setInterval(pollWifiData, 2000);
}

function pollWifiData() {
	var sigSection = docGetElById('wifiSignalSection');
	var noConn = docGetElById('wifiNotConnected');
	if (!sigSection || !noConn) return;
	getData('getwifidata.sh', function(data) {
		if (data.connected) {
			sv('wireless_ap_mac', data.APMAC || '');
			sv('wireless_frequency', data.frequency || '');
			sv('wireless_signal', data.signallevel || '');
			sv('wireless_quality', data.linkquality || '');
			sigSection.style.display = 'block';
			noConn.style.display = 'none';
		} else {
			sigSection.style.display = 'none';
			noConn.style.display = 'block';
		}
	});
}

function stopWifiPoll() {
	if (wifiPollTimer) {
		clearInterval(wifiPollTimer);
		wifiPollTimer = null;
	}
}

function getWiredSettings() {
	return 'iface=eth0' +
		'&dhcp=' + (ov('wired_dhcp') === 'true' ? 'auto' : 'manual') +
		'&ipaddr=' + ov('wired_ipa') +
		'&netmask=' + ov('wired_nm') +
		'&gateway=' + ov('wired_gw') +
		'&dns=' + ov('wired_dns') +
		'&ntp=' + ov('wired_ntp');
}

function getWirelessSettings() {
	return 'iface=wlan0' +
		'&dhcp=' + (ov('wireless_dhcp') === 'true' ? 'auto' : 'manual') +
		'&ipaddr=' + ov('wireless_ipa') +
		'&netmask=' + ov('wireless_nm') +
		'&gateway=' + ov('wireless_gw') +
		'&dns=' + ov('wireless_dns') +
		'&ntp=' + ov('wireless_ntp') +
		'&ssid=' + ov('wireless_ssid') +
		'&passkey=' + ov('wireless_passkey');
}

function saveCommsCfg() {
	var wiredCfg = getWiredSettings();
	var wirelessCfg = getWirelessSettings();

	setData('setethernet.sh', wiredCfg, function(data) {
		setData('setwifi.sh', wirelessCfg, function(data) {
			alertInfo('Success: Communications Settings Saved!');
		});
	});

	return false;
}

function resetCommsCfg() {
	layer = 'layerComms';
	getData('resetcommscfg.sh', function() {
		alertInfo('Success: Communications settings reset to default values');
		loadComms();
	});
}

//-----------------------------------------------------------------------------
// Contact Page TAB/Layer Functions
//-----------------------------------------------------------------------------
function loadContact() {
	showMenuLayer('layerContact');
}

//-----------------------------------------------------------------------------
// Administration Page/Layer Functions
//-----------------------------------------------------------------------------
function loadAdmin() {
	layer = 'layerAdmin';
	showMenuLayer(layer);
}

function saveAdmin() {
	var data = "oldPassword=" + encodeURIComponent(ov('current-password'))
		+ "&newPassword=" + encodeURIComponent(ov('new-password'));

	setData('setpasswd.sh', data, function(resp) {
		alert('Password updated. Please login with your new password.');
		window.location.reload();
	});

	return false;
}

//-----------------------------------------------------------------------------
// Reboot Robot
//-----------------------------------------------------------------------------
function deviceReboot() {
	setData('restart.sh', 'reboot=true', function(data) {
		rebootTime = 20;
		fwRebootTimer();
		alertInfo('Success: Device will reboot in ' + rebootTime);
	});
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

function uuidv4() {
	return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, function(c) {
		return (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16);
	});
}
