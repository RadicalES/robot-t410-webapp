/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React from 'react';
import { Link } from 'react-router-dom'

const RobotNavbar = (props) => {

    return (
        <div className="container container-xss robotNavBar">            
            <nav className="navbar navbar-expand-sm navbar-light" fixed="top">                                            
                <a className="navbar-brand robot-brand" href="#"><img src="robot.png" alt="Robot" height="40"className="d-inline-block"/> T410</a>                
                <div className="navbar-nav">
                    <Link to="/" className="nav-item nav-link">
                        Device
                    </Link>
                    <Link to="/app" className="nav-item nav-link">
                        Application
                    </Link>
                    <Link to="/network" className="nav-item nav-link">
                        Network
                    </Link>
                    <Link to="/admin" className="nav-item nav-link">
                        Admin
                    </Link>
                </div>
            </nav>
        </div> 
    );
}

export default RobotNavbar;