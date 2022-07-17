/**
 * @description       : 
 * @author            : Mark Alvin Tayag (tmalvin.workshop@gmail.com)
 * @group             : 
 * @last modified on  : 07-16-2022
 * @last modified by  : Mark Alvin Tayag (tmalvin.workshop@gmail.com)
**/
public with sharing class CalloutSample {   
    // Pass in the endpoint to be used using the string url
    public static String getCalloutResponseContents(String url, String method) {
        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
    }
}