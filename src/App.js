/* (C) 2020-2022, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React from 'react';
import { Route, createBrowserRouter, createRoutesFromElements, Outlet, RouterProvider } from 'react-router-dom'
import Network, { networkLoader, networkSaveAction } from './components/network'
import DeviceInfo, { devInfoLoader } from './components/device'
import Admin from './components/admin'
import RootLayout from './pages/RootLayout';
import ApplicationPage, { applicationLoader } from './pages/ApplicationPage';
import TelemetryPage from './pages/TelemetryPage';
import EthernetPage, { ethernetLoader } from './pages/EthernetPage';
import WirelessPage, { wirelessLoader } from './pages/WirelessPage';

const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path='/' element={<RootLayout />}>
      <Route
        index          
        element={<DeviceInfo />}
        loader={devInfoLoader}
      />            
      <Route 
        path='/app' 
        element={<ApplicationPage />} 
        loader={applicationLoader}
      />
      <Route 
        path='/telemetry' 
        element={<TelemetryPage />} 
        loader={applicationLoader}
      />
      <Route 
        path='/ethernet' 
        element={<EthernetPage />} 
        loader={ethernetLoader}  
        action={networkSaveAction}
      />
       <Route 
        path='/wifi' 
        element={<WirelessPage />} 
        loader={wirelessLoader}  
        action={networkSaveAction}
      />
      <Route path='/admin' element={<Admin />} />
    </Route>
 
  )
)

function App () {
    return (
      <RouterProvider router={router} />
    );
  
}


export default App;
