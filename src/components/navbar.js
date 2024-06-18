/* (C) 2020-2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React from 'react';
import { Container, Nav, Navbar, NavbarBrand } from 'react-bootstrap';
import { NavLink } from 'react-router-dom'

const RobotNavbar = (props) => {

    return (
        <Navbar>           
            <Container>

                <NavbarBrand className="robot-brand">
                <img src="robot.png" alt="Robot" height="40" />
                {' '} T420
                </NavbarBrand>

                <Nav className="ms-auto">
                    <NavLink to="/" className="nav-item nav-link" >
                        Device
                    </NavLink>
                    <NavLink to="/app" className="nav-item nav-link">
                        Application
                    </NavLink>
                    <NavLink to="/telemetry" className="nav-item nav-link">
                        Telemetry
                    </NavLink>
                    <NavLink to="/ethernet" className="nav-item nav-link">
                        Ethernet
                    </NavLink>
                    <NavLink to="/wifi" className="nav-item nav-link">
                        Wifi
                    </NavLink>
                    <NavLink to="/admin" className="nav-item nav-link">
                        Admin
                    </NavLink>
                </Nav>

            </Container> 
        </Navbar> 
    );
}

export default RobotNavbar;