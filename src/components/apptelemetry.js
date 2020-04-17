import React, { useState, useEffect, useRef } from 'react';


const AppTelemetry = ({ config, handleChange }) => {
    const appTMenable = useRef();
    const appTMbroker = useRef();
    const appTMtopic = useRef();
    const appTMport = useRef();

    const [ Updated, setUpdated] = useState(0);
    const [ BrokerStyle, setBrokerStyle] = useState({ borderColor: "" });
    const [ PortStyle, setPortStyle] = useState({ borderColor: "" });

    useEffect( () => {        
        if(Updated < 2) {
            appTMenable.current.checked = config.enabled === "TRUE";
            appTMbroker.current.value = config.broker;
            appTMtopic.current.value = config.pubtopic;
            appTMport.current.value = config.port;
            setUpdated(Updated + 1);
        }
    }, [config])


    const changeErrorStyle = (field, error) => {
        let s = {borderColor: ""};

        if(error === false) {            
            s = {borderColor: "red"};
        }

        if(field === "broker") {
            setBrokerStyle(s);
        }
        else if(field === "port") {
            setPortStyle(s);
        }
    }


    return ( 
        <div className="network-content">                        
            
                <div className="form-group app-group">
                    <div className="custom-control custom-switch">                    
                        <input className="custom-control-input" type="checkbox" id="telemcb"
                            ref={appTMenable}
                            onChange={(e) => { handleChange('enabled', e.target.checked)}}  
                            />
                        <label htmlFor="telemcb" className="custom-control-label col-form-label-sm">Enable Telemetry</label>                    
                    </div>
                </div>

                <div className="form-group app-group">                
                <label htmlFor="telembroker" className="col-form-label col-form-label-sm applabel">Broker:</label>
                <input type="url" className="form-control form-control-sm appurl" id="telembroker" 
                    ref={appTMbroker}
                    style={BrokerStyle}
                    onChange={( (e) => { const err = handleChange('broker', e.target.value); changeErrorStyle('broker', err);  })}
                    />
                </div>

                <div className="form-group app-group">
                <label htmlFor="telemport" className="col-form-label col-form-label-sm applabel">Port:</label>
                <input type="number" className="form-control form-control-sm appurl" id="telemport" min="100" max="65535"
                    ref={appTMport}
                    style={PortStyle}
                    onChange={( (e) => { const err = handleChange('port', e.target.value); changeErrorStyle('port', err); })}
                    />
                </div>

                <div className="form-group app-group">
                <label htmlFor="telemtopic" className="col-form-label col-form-label-sm applabel">Publish Topic:</label>
                <input type="text" className="form-control form-control-sm appurl" id="telemtopic" 
                    ref={appTMtopic}
                    onChange={( (e) => { handleChange('pubtopic', e.target.value) })}
                    />
                </div>

        </div>

    )
}

export default AppTelemetry;