/* (C) 2020-2022, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React from 'react';
import { Route, createBrowserRouter, createRoutesFromElements, Outlet, RouterProvider } from 'react-router-dom'
import Network, { networkLoader, networkSaveAction } from './components/network'
import DeviceInfo, { devInfoLoader } from './components/device'
import Admin from './components/admin'
import RootLayout from './components/RootLayout';
import ApplicationPage, { applicationLoader } from './pages/ApplicationPage';

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
        path='/network' 
        element={<Network />} 
        loader={networkLoader}  
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
