/* (C) 2020-2022, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React from 'react';
import { Route, createBrowserRouter, createRoutesFromElements, Outlet, RouterProvider } from 'react-router-dom'
import Network, { networkLoader, networkSaveAction } from './components/network'
import DeviceInfoPage, { deviceInfoLoader } from './pages/DeviceInfoPage'
import RootLayout from './pages/RootLayout';
import ApplicationPage, { applicationLoader } from './pages/ApplicationPage';
import TelemetryPage, { telemetryLoader } from './pages/TelemetryPage';
import EthernetPage, { ethernetLoader } from './pages/EthernetPage';
import WirelessPage, { wirelessLoader } from './pages/WirelessPage';
import AdminPage from './pages/AdminPage';

const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path='/' element={<RootLayout />}>
      <Route
        index          
        element={<DeviceInfoPage />}
        loader={deviceInfoLoader}
      />            
      <Route 
        path='/app' 
        element={<ApplicationPage />} 
        loader={applicationLoader}
      />
      <Route 
        path='/telemetry' 
        element={<TelemetryPage />} 
        loader={telemetryLoader}
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
      <Route path='/admin' element={<AdminPage />} />
    </Route>
 
  )
)

function App () {
    return (
      <RouterProvider router={router} />
    );
  
}


export default App;
