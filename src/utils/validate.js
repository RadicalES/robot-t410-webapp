


const Validation = {


    IPAddress : (obj, paramsObj) => {
        const params = paramsObj || {};
        const message = (params.failureMessage !== undefined) ? params.failureMessage : "Must be a valid IP Address/Subnet Mask!";
        const ary = obj.split(".");
        let ip = true;
        
        for (let i in ary) { 
            ip = (!ary[i].match(/^\d{1,3}$/) || (Number(ary[i]) > 255)) ? false : ip; 
        }

        return (ary.length != 4) ? false : ip;
    },

    MQTTTopic : (topic, params) => {
        return false;
    },

    UrlCheck : (url, params) => {
        const regex = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
        return regex.test(url);
    },

    Numericality : (value, params) => {
        var suppliedValue = value;
        var value = Number(value);
    	var paramsObj = params || {};
        var minimum = ((paramsObj.minimum) || (paramsObj.minimum == 0)) ? paramsObj.minimum : null;;
        var maximum = ((paramsObj.maximum) || (paramsObj.maximum == 0)) ? paramsObj.maximum : null;
    	var is = ((paramsObj.is) || (paramsObj.is == 0)) ? paramsObj.is : null;
        var notANumberMessage = paramsObj.notANumberMessage || "Must be a number!";
        var notAnIntegerMessage = paramsObj.notAnIntegerMessage || "Must be an integer!";
    	var wrongNumberMessage = paramsObj.wrongNumberMessage || "Must be " + is + "!";
    	var tooLowMessage = paramsObj.tooLowMessage || "Must not be less than " + minimum + "!";
    	var tooHighMessage = paramsObj.tooHighMessage || "Must not be more than " + maximum + "!";
        if (!isFinite(value)) return false;
        if (paramsObj.onlyInteger && (/\.0+$|\.$/.test(String(suppliedValue))  || value != parseInt(value)) ) return false;
    	switch(true){
    	  	case (is !== null):
    	  		if( value != Number(is) ) return false;
    			break;
    	  	case (minimum !== null && maximum !== null):
    	  		if(!Validation.Numericality(value, {tooLowMessage: tooLowMessage, minimum: minimum})) return false;
    	  		if(!Validation.Numericality(value, {tooHighMessage: tooHighMessage, maximum: maximum})) return false;
    	  		break;
    	  	case (minimum !== null):
    	  		if( value < Number(minimum) ) return false;
    			break;
    	  	case (maximum !== null):
    	  		if( value > Number(maximum) ) return false;
    			break;
    	}
    	return true;
    },

}

export default Validation;
