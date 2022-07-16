/**
 * @description       : 
 * @author            : Mark Alvin Tayag (tmalvin.workshop@gmail.com)
 * @group             : 
 * @last modified on  : 07-16-2022
 * @last modified by  : Mark Alvin Tayag (tmalvin.workshop@gmail.com)
**/
@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {

    public List<Mock_Callout_Mapping__mdt> mockCalloutList = new List<Mock_Callout_Mapping__mdt>();
    public Map<String, String> srMockMap = new Map<String, String>(); //Name + JSON map
    public String CONTENT_TYPE = 'application/json';
    public Boolean sendSuccess = true;

    public MockHttpResponseGenerator(Boolean isSuccess) {
        sendSuccess = isSuccess;
        Set<String> srNames = new Set<String>();
        for (Mock_Callout_Mapping__mdt md : [SELECT Endpoint__c, Include_Params__c, 
                                Success_HTTP_Code__c, Success_Method__c, Success_Static_Resource_Name__c,
                                Error_HTTP_Code__c, Error_Method__c, Error_Static_Resource_Name__c
                                FROM Mock_Callout_Mapping__mdt]) {
            if (String.isNotEmpty(md.Success_Static_Resource_Name__c)) { srNames.add(md.Success_Static_Resource_Name__c); }
            if (String.isNotEmpty(md.Error_Static_Resource_Name__c)) { srNames.add(md.Error_Static_Resource_Name__c); }
            mockCalloutList.add(md);
        }
        
        for (StaticResource sr : [SELECT Name, Body FROM StaticResource WHERE ContentType =: CONTENT_TYPE AND Name =: srNames]) {
            srMockMap.put(sr.Name, sr.Body.toString());
        }
    }
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        Mock_Callout_Mapping__mdt md = findMD(req);

        if (String.isEmpty(md.Endpoint__c)) {
            System.assert(false, 'Endpoint mismatch');
        }

        //SUCCESS
        if (sendSuccess == true && (String.isEmpty(md.Success_Static_Resource_Name__c) || !srMockMap.containsKey(md.Success_Static_Resource_Name__c))) {
            System.assert(false, 'JSON Response is not available');
        }
        
        if (md.Success_Method__c == req.getMethod() && sendSuccess == true) {
            res.setHeader('Content-Type', CONTENT_TYPE);
            res.setBody(srMockMap.get(md.Success_Static_Resource_Name__c));
            res.setStatusCode(Integer.valueOf(md.Success_HTTP_Code__c));
        }

        //ERROR
        if (sendSuccess == false && (String.isEmpty(md.Error_Static_Resource_Name__c) || !srMockMap.containsKey(md.Error_Static_Resource_Name__c))) {
            System.assert(false, 'JSON Response is not available');
        }

        if (md.Error_Method__c == req.getMethod() && sendSuccess == false) {
            res.setHeader('Content-Type', CONTENT_TYPE);
            res.setBody(srMockMap.get(md.Error_Static_Resource_Name__c));
            res.setStatusCode(Integer.valueOf(md.Error_HTTP_Code__c));
        }

        return res;
    }

    private Mock_Callout_Mapping__mdt findMD (HttpRequest req) {
        Mock_Callout_Mapping__mdt md = new Mock_Callout_Mapping__mdt();

        for (Mock_Callout_Mapping__mdt meta : mockCalloutList) {
            if ((meta.Endpoint__c == req.getEndpoint() && meta.Include_Params__c == true) || 
                (meta.Endpoint__c.startsWith(req.getEndpoint()) && meta.Include_Params__c == false)) {
                    md = meta;
                    break;
                }
        }

        return md;
    }
}