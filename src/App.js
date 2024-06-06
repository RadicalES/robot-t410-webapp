/* (C) 2020-2022, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React from 'react';
import RobotNavbar from './components/navbar'
import { Route, BrowserRouter, Routes, useLocation, createBrowserRouter, createRoutesFromElements, Outlet, RouterProvider } from 'react-router-dom'
import Application from './components/application'
import Network from './components/network'
import DeviceInfo, { devInfoLoader } from './components/device'
import Admin from './components/admin'
import RootLayout from './components/RootLayout';

const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path='/' element={<RootLayout />}>
      <Route
        index          
        element={<DeviceInfo />}
        loader={devInfoLoader}
        />            
      <Route path='/app' element={<Application />} />
      <Route path='/network' element={<Network />} />
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
