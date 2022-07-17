/* (C) 2020-2022, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React from 'react';
import { NavLink } from 'react-router-dom'

const RobotNavbar = (props) => {

    return (
        <div className="container container-xss robotNavBar">            
            <nav className="navbar navbar-expand-sm navbar-light" fixed="top">                                            
                <a className="navbar-brand robot-brand" href="#"><img src="robot.png" alt="Robot" height="40" className="d-inline-block"/> T420</a>                
                <div className="navbar-nav">
                    <NavLink to="/" exact className="nav-item nav-link" activeClassName="active" >
                        Device
                    </NavLink>
                    <NavLink to="/app" className="nav-item nav-link" activeClassName="active">
                        Application
                    </NavLink>
                    <NavLink to="/network" className="nav-item nav-link" activeClassName="active">
                        Network
                    </NavLink>
                    <NavLink to="/admin" className="nav-item nav-link" activeClassName="active">
                        Admin
                    </NavLink>
                </div>
            </nav>
        </div> 
    );
}

export default RobotNavbar;