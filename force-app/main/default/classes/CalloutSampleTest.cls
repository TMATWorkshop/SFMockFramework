/**
 * @description       : 
 * @author            : Mark Alvin Tayag (tmalvin.workshop@gmail.com)
 * @group             : 
 * @last modified on  : 07-16-2022
 * @last modified by  : Mark Alvin Tayag (tmalvin.workshop@gmail.com)
**/
@isTest
public class CalloutSampleTest {
    @IsTest
    static void testSuccessCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true));
        
        List<Mock_Callout_Mapping__mdt> mdList = [SELECT Endpoint__c, Include_Params__c, 
                                                    Success_HTTP_Code__c, Success_Method__c, Success_Static_Resource_Name__c,
                                                    Error_HTTP_Code__c, Error_Method__c, Error_Static_Resource_Name__c
                                                    FROM Mock_Callout_Mapping__mdt
                                                    WHERE DeveloperName='AWS'];
        List<StaticResource> srList = [SELECT Name, Body FROM StaticResource WHERE Name =: mdList[0].Success_Static_Resource_Name__c];

        Test.startTest();
        String jsonStr = CalloutSample.getCalloutResponseContents(mdList[0].Endpoint__c, mdList[0].Success_Method__c);
        Test.stopTest();
        System.assertEquals(srList[0].Body.toString(), jsonStr);
    }
    
    @IsTest
    static void testErrorCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        
        List<Mock_Callout_Mapping__mdt> mdList = [SELECT Endpoint__c, Include_Params__c, 
                                                    Success_HTTP_Code__c, Success_Method__c, Success_Static_Resource_Name__c,
                                                    Error_HTTP_Code__c, Error_Method__c, Error_Static_Resource_Name__c
                                                    FROM Mock_Callout_Mapping__mdt
                                                    WHERE DeveloperName='AWS'];
        List<StaticResource> srList = [SELECT Name, Body FROM StaticResource WHERE Name =: mdList[0].Error_Static_Resource_Name__c];

        Test.startTest();
        String jsonStr = CalloutSample.getCalloutResponseContents(mdList[0].Endpoint__c, mdList[0].Error_Method__c);
        Test.stopTest();
        System.assertEquals(srList[0].Body.toString(), jsonStr);
    }
}