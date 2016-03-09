//
//  ServerRequestController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "ServerRequestController.h"

@interface ServerRequestController ()  <NSURLSessionDelegate, NSURLSessionDataDelegate>

@end


@implementation ServerRequestController

- (instancetype)init {
    
    self = [super init];
    if (self) {
        //einen neuen Array von DataTasks  für die Session erstellen
        self.dataTasks = [NSMutableArray new];
        
        //create a new NSURLSession
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    
    return self;
}

- (instancetype)initWithUser:(User *)user {
    self = [self init];
    
    if (self) {
        self.associatedUser = user;
        
    }
    
    return self;
}


- (NSURLSessionDataTask *)dataTaskForURL:(NSURL *)requestURL withParameterDict:(NSDictionary *)parameters {
    if (requestURL && self.associatedUser) {
        __block NSString *sendParameterString = @"";
        
        //die Parameter und Passworter an die URL anhängen
        //erst die Parameter
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            sendParameterString = [sendParameterString stringByAppendingFormat:@"%@=%@&", key, obj];
        }];
        
        //dann das Passwort und den Benutzernamen an die URL anhängen
        sendParameterString = [sendParameterString stringByAppendingFormat:@"username=%@&pw=%@", self.associatedUser.benutzername, self.associatedUser.password];
        
        //dann eine URL-Request erstellen
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        
        //    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
        //Here you send your data
        [request setHTTPBody:[sendParameterString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPMethod:@"POST"];
        
        //jetzt den Download-Task erstellen
        NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (error) {
                //Höchstwahrscheinlich ein Verbindungsfehler, der als ein solcher ausgegeben werden muss
                //Die entsprechende Methode vom Delegate aufrufen
                if ([self.delegate respondsToSelector:@selector(didFinishDownloadingDataTask:withData:andError:forServerRequest:)]) {
                    [self.delegate didFinishDownloadingDataTask:dataTask withData:data andError:error forServerRequest:self];
                }
            }
            //Fehler 400 meint, dass nicht genügend Parameter übergeben wurden, 401 sagt, dass entweder Passwort oder Benutzername oder beides falsch ist
            else if (httpResponse.statusCode == 400) {
                //Fehler melden an Systemadministrator
                ///dürfte nicht vorkommen...
                NSLog(@"Fehler beim Download! Nicht genügend Parameter übergeben! %@", response);
                
            }
            else if (httpResponse.statusCode == 401) {
                //App sperren, weil vorhandene Benutzerdaten falsch sind --> Anmelde-Maske anzeigen
                
            }
            else {
                //Die entsprechende Methode vom Delegate aufrufen
                if ([self.delegate respondsToSelector:@selector(didFinishDownloadingDataTask:withData:andError:forServerRequest:)]) {
                    [self.delegate didFinishDownloadingDataTask:dataTask withData:data andError:error forServerRequest:self];
                }
            }
        }];
        
        //zum dataTaks array hinzufügen
        [self.dataTasks addObject:dataTask];
        
        return dataTask;
    }
    
    return nil;
}

- (void)startRequests {
    for (NSURLSessionDataTask *dataTask in self.dataTasks) {
        [dataTask resume];
    }
}


#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    
}
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    
}


@end
