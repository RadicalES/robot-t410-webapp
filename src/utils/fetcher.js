/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
const Fetcher = async (path, method, payload) => {
    let params = {        
        method: method,
        cache: 'no-cache',
        credentials: 'same-origin',
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials':true,
            'Access-Control-Allow-Methods':'POST, GET'
        },        
    }

    if(method === 'POST') {
        params['body'] = payload;
    }

    try {
        const resp = await fetch(path, params);
        const data = await resp.json()
        return {     
            status: 'OK',       
            data: data,
            error: null
        }

    } catch(error) {
        return {
            status: 'FAIL',
            data: { status: 'FAIL' },
            error: error
        }
    }

}

export default Fetcher;