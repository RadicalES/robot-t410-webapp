
import React from "react";
import RobotNavbar from "./navbar";
import { Outlet } from "react-router-dom";

export default function RootLayout() {

    return (
        <div className="App">
          <RobotNavbar />
          <Outlet />
          <div className="container footer">
            <div className="smallText">
                &copy; 2024 Radical Electronic Systems&nbsp;|&nbsp;            
                <a href="http://www.radicalsystems.co.za">www.radicalsystems.co.za</a>&nbsp;|&nbsp;            
                <a href="mailto:info@radicalsystems.co.za">info@radicalsystems.co.za</a>&nbsp;|&nbsp;
                <span>ver 2.0</span>
            </div>
          </div>
        </div>
    )

}