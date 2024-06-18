
import React from "react";
import RobotNavbar from "../components/NavBar";
import { Outlet, useNavigation } from "react-router-dom";
import { Container, Spinner } from "react-bootstrap";

export default function RootLayout() {

  const { state } = useNavigation();

    return (
        <Container className="app">
          <RobotNavbar />

          { state === "loading" ?
            <Container className="content">
              <Spinner animation='border' role="status">
                <span className="visually-hidden">Loading...</span>
              </Spinner>
            </Container>
          : <Outlet /> }
          
          <Container className="footer">
            <div className="smallText">
                &copy; 2024 Radical Electronic Systems&nbsp;|&nbsp;            
                <a href="http://www.radicalsystems.co.za">www.radicalsystems.co.za</a>&nbsp;|&nbsp;            
                <a href="mailto:info@radicalsystems.co.za">info@radicalsystems.co.za</a>&nbsp;|&nbsp;
                <span>ver 2.0</span>
            </div>
          </Container>
        </Container>
    )

}