'use strict';
exports.handler = (event, context, callback) => {

  //Get contents of response
  const response = event.Records[0].cf.response;
  delete response.headers.server;
  const headers = response.headers;

  //Set new headers 
  headers['Report-To'] = [{
    key: 'Report-To',
    value: '{"group":"report-uri", "max_age":31536000, "endpoints":[{"url":"https://jerusdp.report-uri.com/a/d/g"}], "include_subdomains":true}'
  }];
  headers['strict-transport-security'] = [{
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubdomains; preload'
  }];
  headers['Content-Security-Policy'] = [{
    key: 'Content-Security-Policy',
    value: "connect-src cmp.osano.com cdnjs.cloudflare.com 'self'; font-src 'self'; img-src 'self' data: 'self' ; script-src 'self'; style-src 'self' ; frame-src ; base-uri 'self'; frame-ancestors 'none'; default-src 'self'; form-action 'self'; report-uri https://jerusdp.report-uri.com/r/d/g; report-to report-uri"
  }];
  headers['Cache-Control'] = [{ key: 'Cache-Control', value: 'max-age=260000' }];
  headers['Cross-Origin-Embedder-Policy-Report-Only'] = [{ key: 'Cross-Origin-Embedder-Policy-Report-Only', value: 'require-corp; report-to report-uri' }];
  headers['Cross-Origin-Opener-Policy'] = [{ key: 'Cross-Origin-Opener-Policy', value: 'same-origin' }];
  headers['x-content-type-options'] = [{ key: 'X-Content-Type-Options', value: 'nosniff' }];
  headers['x-xss-protection'] = [{ key: 'X-XSS-Protection', value: '1; mode=block' }];
  headers['referrer-policy'] = [{ key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' }];

  //Return modified response
  callback(null, response);
};