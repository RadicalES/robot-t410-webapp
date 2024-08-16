//V3.01.A - http://www.openjs.com/scripts/jx/
//Adapted by Radical Electronic Systems to support embedded systems
//13/12/2022 - V3.01.D, json for for promise reject, refactor completion logic
//07/11/2018 - V3.01.C, Add GET_LONG method to disable wait cursor indication when polling long events 
//01/03/2018 - V3.01.B, First Release
jx = {
	//Create a xmlHttpRequest object - this is the constructor.
	getHTTPObject : function() {
		var http = false;
		//Use IE's ActiveX items to load the file.
		if(typeof ActiveXObject != 'undefined') {
			try {http = new ActiveXObject("Msxml2.XMLHTTP");}
			catch (e) {
				try {http = new ActiveXObject("Microsoft.XMLHTTP");}
				catch (E) {http = false;}
			}
		//If ActiveX is not available, use the XMLHttpRequest of Firefox/Mozilla etc. to load the document.
		} else if (window.XMLHttpRequest) {
			try {
				http = new XMLHttpRequest();
				if(http.withCredentials === undefined) {
					console.log("IE8/9 XDomainRequest");
					http = new XDomainRequest();
				}
			}
			catch (e) {
				http = false;
			}
		}
		return http;
	},
	// This function is called from the user's script.
	//Arguments -
	//	url	- The url of the serverside script that is to be called. Append all the arguments to
	//			this url - eg. 'get_data.php?id=5&car=benz'
	//	callback - Function that must be called once the data is ready.
	//	format - The return type for this function. Could be 'xml','json' or 'text'. If it is json,
	//			the string will be 'eval'ed before returning it. Default:'text'
	load : function (url,format,method,opt,uuid,data) {
		return new Promise(function(resolve, reject) {
				var http = this.init(); //The XMLHttpRequest object is recreated at every call - to defeat Cache problem in IE
				var _this = this;
				let param = "";
				if(!http||!url) reject("AJAX object or url invalid!");
				if(!format) format = "text";//Default return type is 'text'
				if(!opt) opt = {};
				if(!data) data = "";
				if(!method) method = "GET";
				http.withCredentials = true; // needed for CORS
				format = format.toLowerCase();
				method = method.toUpperCase();

				if(url.indexOf("\?") > -1) {
					//if(method=="POST") {
						var parts = url.split("\?");
						url = parts[0];
						param = parts[1];
					//}
				}
				
				let now = 'tm=' + new Date().getTime();
				url += '\?uid=' + uuid + '&' + now;
				
				if((method=="GET") && (param.length > 1)) {
					url += '&' + param;
					param = {};
				}

				if(method=="GET_LONG") {
					method = "GET";
				}
				else {
					this.waitC(opt);
				}

				// if object convert to json
				if(data === Object(data)) {
					data = JSON.stringify(data)
				}

				http.open(method, url, true);

		//		var params = typeof data == 'string' ? data : Object.keys(data).map(
		  //          function(k){ return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]) }
		    //    ).join('&');

				http.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
				http.setRequestHeader('x-mac', 'AA:BB:CC:00:11:22');

				if((method=="POST") && (param.length > 0)) {
					http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
					//http.setRequestHeader("Content-length", param.length);
					//http.setRequestHeader("Connection", "close");
				}
				else if((method=="POST") && (data.length > 0)) {
					http.setRequestHeader("Content-type", "application/json");
					//http.setRequestHeader("Content-length", param.length);
					//http.setRequestHeader("Connection", "close");
				}
				else if(method=="POST") {
					http.abort();
					this.completeC(opt);
					reject({
						status: 0,
						message: "POST error, has not data or parameters!"
					});
				}

				/*0: UNSENT, 1: OPEN, 2:HEADERS_RECEIVED, 3: LOADING, 4: DONE*/
				http.onreadystatechange = function () {//Call a function when the state changes.
					if (http.readyState == 4) {//Ready State will be 4 when the document is loaded.
						const ct = http.getResponseHeader("content-type") || "";
						var res = "";
						const isJson = ct.indexOf('json') > -1;
						const isHtml = ct.indexOf('html') > -1;
						
						if(http.status == 200) {

							_this.completeC(opt);

							if(isHtml) {
								resolve({
									status: http.status,
									message: "HTML not supported"
								});
							}
							else if(isJson) {
								resolve(JSON.parse(http.responseText));
							}
							else {
								reject({
									status: http.status,
									message: "Content not supported: " + ct
								});
							}
						}
						else { //An error occured
							var err = {
								status: http.status,
								message: "Unknown"
							};

							if(isJson) {
								const msg = JSON.parse(http.responseText);
								err.message = msg.message;
								err.result = msg.status;
							}

							_this.completeC(opt);
							reject(err);
						}
					}
				};

				if(param.length > 0) {
					http.send(param);
				}
				else if(data.length > 0) {
					http.send(data);
				}
				else {
					http.send(null);
				}
			}.bind(this));
	},
	waitC : function(opt) {
		document.body.style.cursor = "wait";
	},
	completeC : function(opt) {
		document.body.style.cursor = 'default';
	},
	init : function() {
		return this.getHTTPObject();
	}
}
