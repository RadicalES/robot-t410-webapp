
const Fetcher = (path, method, payload, response) => {
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

    fetch(path, params)
    .then( (res) => {
        return res.json()                
    })
    .then( (res) => {
        const d = {     
            status: 'OK',       
            data: res,
            error: null
        }
        response(d)        
    })
    .catch( (error) => {
        response({
            status: 'FAIL',
            data: { status: 'FAIL' },
            error: error
        })
    })

}

export default Fetcher;