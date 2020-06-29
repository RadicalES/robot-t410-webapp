/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useRef } from 'react';
import Fetcher from '../utils/fetcher'

const Admin = () => {
    const curPass = useRef();
    const newPass = useRef();
    const confirmPass = useRef();

    const rebootResult = (result) => {        
        const { status } = result.data;        

        console.log("REBOOT : ", result);

        if(status === 'OK') {
            alert("Device will reboot!");
        }
        else {
            alert("Failed to reboot");
        }
    }

    const setResult = (result) => {        
        const { status } = result.data;    
        if(status === 'OK') {
            alert("Password changed!");
        }
        else {
            alert("Failed to change password!");
        }
    }    

    const handleSubmit = (e) => {
        e.preventDefault();
        const pn = curPass.current.value;
        const pc = newPass.current.value;
        
        if(pn === pc) { 
            const cfg = 'password=' + curPass.current.value + 
                    '&newPassword=' + newPass.current.value;

            Fetcher('/cgi/setpasswd.sh', 'POST', cfg, setResult );
        }
        else {
            alert("Passwords do not match!")
        }
        return true;
    }

    const handleReboot = (e) => {
        const d = 'restart=restart'
        Fetcher('/cgi/restart.sh', 'POST', d, rebootResult );
    }

    return (

        <div className="container content" onSubmit={handleSubmit} noValidate>
            <form>
                <h4>Admistration Tasks</h4> 
                <div className="form-group app-group">
                    <label htmlFor="currentPassword" className="col-form-label col-form-label-sm applabel">Current Password:</label>
                    <input type="password" className="form-control form-control-sm appipmac" id="currentPassword" ref={curPass}/>                    
                </div>
                <div className="form-group app-group">
                    <label htmlFor="newPassword" className="col-form-label col-form-label-sm applabel">New Password:</label>
                    <input type="password" className="form-control form-control-sm appipmac" id="newPassword" ref={newPass}/>                    
                </div>
                <div className="form-group app-group">
                    <label htmlFor="confirmPassword" className="col-form-label col-form-label-sm applabel">Confirm Password:</label>
                    <input type="password" className="form-control form-control-sm appipmac" id="confirmPassword" ref={confirmPass}/>                    
                </div>
                <button type="submit" className="btn btn-secondary btn-sm appbtn">Save Password</button>
                <button type="button" className="btn btn-secondary btn-sm appbtn" onClick={handleReboot} >Reboot</button>         
            </form>
        </div>
        
    )

}

export default Admin;