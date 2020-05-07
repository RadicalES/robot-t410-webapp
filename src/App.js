/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React from 'react';
import RobotNavbar from './components/navbar'
import { Route, BrowserRouter, Switch } from 'react-router-dom'
import Application from './components/application'
import Network from './components/network'
import DeviceInfo from './components/device'
import Admin from './components/admin'

function App () {
  
    return (
      <BrowserRouter>
        <div className="App">
          <RobotNavbar />
          <Switch>
            <Route exact path='/'><DeviceInfo /> </Route>            
            <Route path='/app' component={Application} />
            <Route path='/network' component={Network} />
            <Route path='/admin' component={Admin} />
          </Switch>        
          <div className="container footer">
	          <div className="smallText">
		        &copy; 2020 Radical Electronic Systems&nbsp;|&nbsp;            
		        <a href="http://www.radicalsystems.co.za">www.radicalsystems.co.za</a>&nbsp;|&nbsp;            
            <a href="mailto:info@radicalsystems.co.za">info@radicalsystems.co.za</a>&nbsp;|&nbsp;
            <span>ver 1.0</span>
	        </div>
          </div>
        </div>
      </BrowserRouter>
    );
  
}


export default App;
