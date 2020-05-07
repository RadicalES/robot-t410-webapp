/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect } from 'react';
import Fetcher from '../utils/fetcher'

const DeviceInfo = () => {

    const [ RobotInfo, setRobotInfo ] = useState({
        data: {
            operatingsystem: "Waiting..."
        },
    });

    useEffect( () => {
        let inView = true;
        Fetcher('/cgi/getinfo.sh', 'GET', null, (data) => { if(inView) setRobotInfo(data) });
        return () => {inView = false;}
    }, [])

    return (

        <div className="container content">
            <h4>Device Information</h4>         
            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">Operating System:</label>
                <label className="form-control form-control-sm appipmac readonly-field">{RobotInfo.data.operatingsystem}</label> 
            </div>
            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">Distribution:</label>
                <label className="form-control form-control-sm appipmac readonly-field">{RobotInfo.data.distro}</label> 
            </div>    
            <div className="form-group app-group">                
                <label className="col-form-label col-form-label-sm applabel">Linux Kernel:</label>                
                <label className="form-control form-control-sm appipmac readonly-field">{RobotInfo.data.kernel}</label> 
            </div>    
            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">MAC Address:</label>
                <label className="form-control form-control-sm appipmac readonly-field">{RobotInfo.data.macaddress}</label> 
            </div>                
        </div>

    )

}

export default DeviceInfo;