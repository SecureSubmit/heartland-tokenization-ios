//
//  SoapHandler.m
//  SecureSubmit
//
//  Created by Roberts, Jerry on 7/10/14.
//  Copyright (c) 2014 Heartland Payment Systems. All rights reserved.
//

#include "tinyxml.h"

#import "SoapHandler.h"

NSString *const PorticoDefaultXmlns = @"hps";

NSString *const PorticoDefaultSchemaUri = @"http://Hps.Exchange.PosGateway";

@interface SoapHandler()

+ (TiXmlElement *) toXmlElement:(NSDictionary *)dictionary
                        forRoot:(TiXmlElement *)root;

+ (NSMutableDictionary *) fromXmlElement:(TiXmlElement *)element
                                  toRoot:(NSMutableDictionary *)root;

@end

@implementation SoapHandler

+ (NSString *) toSoap:(NSDictionary *) request
            namespace:(NSString *) xmlns
            schemaUri:(NSString *)uri
{
    TiXmlDocument doc;
    
    TiXmlDeclaration *decl = new TiXmlDeclaration("1.0", "", "");
    
    doc.LinkEndChild(decl);
    
    TiXmlElement *soapEnvelope = doc.InsertEndChild(TiXmlElement("SOAP:Envelope"))->ToElement();
    
    soapEnvelope->SetAttribute("xmlns:SOAP", "http://schemas.xmlsoap.org/soap/envelope/");
    
    const char * fullNamespace = [[NSString stringWithFormat:@"xmlns:%@", xmlns] UTF8String];
    
    soapEnvelope->SetAttribute(fullNamespace, [uri UTF8String]);
    
    TiXmlElement *soapBody = soapEnvelope->InsertEndChild(TiXmlElement("SOAP:Body"))->ToElement();
    
    [self toXmlElement:request
               forRoot:soapBody];
    
    TiXmlPrinter printer;
    
    doc.Accept(&printer);
    
    const char *text = printer.CStr();
    
    return [NSString stringWithUTF8String:text];
}

+ (NSDictionary *) fromSoap:(NSString *) response
{
    TiXmlDocument doc;
    
    doc.Parse([response UTF8String]);
    
    TiXmlElement *soapEnvelope = doc.RootElement();
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [self fromXmlElement:soapEnvelope
                  toRoot:result];
    
    return result;
}

+ (TiXmlElement *) toXmlElement:(NSDictionary *)dictionary
                        forRoot:(TiXmlElement *)root
{
    for(NSString *currentKey in [dictionary allKeys])
    {
        id currentValue = [dictionary valueForKey:currentKey];
        
        if( [[NSString stringWithFormat:@"%@", currentValue] length] == 0)
        {
            continue;
        }
        
        const char * elementName = [[NSString stringWithFormat:@"hps:%@", currentKey] UTF8String];
        
        TiXmlElement *currentElement = root->InsertEndChild(TiXmlElement(elementName))->ToElement();
        
        if([currentValue isKindOfClass:[NSDictionary class]])
        {
            [self toXmlElement:currentValue
                       forRoot:currentElement];
        }
        else
        {
            const char * value = [[NSString stringWithFormat:@"%@", currentValue] UTF8String];
            
            TiXmlText *currentElementValue = new TiXmlText(value);
            
            currentElement->LinkEndChild(currentElementValue);
        }
    }
    
    return root;
}

+ (NSMutableDictionary *) fromXmlElement:(TiXmlElement *)element
                                  toRoot:(NSMutableDictionary *)root
{
    TiXmlNode *child = 0;
    
    while ((child = element->IterateChildren(child)))
    {
        const char *elementName = child->Value();
        
        TiXmlText *xmlText = dynamic_cast<TiXmlText*>(child->FirstChild());
        
        if(xmlText)
        {
            [root setObject:[NSString stringWithUTF8String:xmlText->Value()]
                     forKey:[NSString stringWithUTF8String:elementName]];
        }
        else
        {
            NSMutableDictionary *childElements = [NSMutableDictionary dictionaryWithCapacity:1];
            
            [self fromXmlElement:child->ToElement()
                          toRoot:childElements];
            
            [root setObject:childElements forKey:[NSString stringWithUTF8String:elementName]];
        }

    }
    
    return root;
}

@end
