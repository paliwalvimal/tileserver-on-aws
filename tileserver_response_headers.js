async function handler(event) {
    var response = event.response;
    var headers = response.headers;

    // Set CORS headers
    // Since JavaScript doesn't allow for hyphens in variable names, we use the dict["key"] notation.
    console.log("Adding CORS headers");
    response.headers['access-control-allow-origin'] = {
        value: '${cors_origin_domain}'
    };
    response.headers['access-control-allow-methods'] = {
        value: 'GET, OPTIONS'
    };
    response.headers['access-control-allow-headers'] = {
        value: 'Authorization'
    };

    if ('${cors_origin_domain}' !== '*') {
        response.headers['access-control-allow-credentials'] = {
            value: 'true'
        };
    }
    
    // Set HTTP security headers
    // Since JavaScript doesn't allow for hyphens in variable names, we use the dict["key"] notation
    console.log("Adding security headers");
    headers['strict-transport-security'] = {
        value: 'max-age=63072000; includeSubdomains; preload'
    };
    headers['x-content-type-options'] = {
        value: 'nosniff'
    };
    headers['x-frame-options'] = {
        value: 'DENY'
    };
    headers['x-xss-protection'] = {
        value: '1; mode=block'
    };
    headers['referrer-policy'] = {
        value: 'no-referrer-when-downgrade'
    };

    // Remove the Server header
    delete headers['server'];

    // Return the response to viewers
    return response;
}
