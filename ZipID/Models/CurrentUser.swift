//
//  CurrentUser.swift
//  ZipID
//
//  Created by Damien Hill on 16/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc class CurrentUser: NSObject {
    
    static let secureSecret = "3d83bfddc@$43fb!de6#14f6a1b56ee0937438#@$232"
    static let sharedInstance = CurrentUser()
    
    var agentId: String?
    var agentUserName: String?
    var lastUsedUserName: String?
    var authToken: String?
    var allowedVerificationTypes: Array<ZPVerificationType> = []
    var rememberUsername: Bool = false
    var brokerFor: Array<Account> = []
    
    var toggles: Dictionary<ToggleName, Toggle> = [:]
    var permissions: Dictionary<PermissionName, Permission> = [:]
  
    
    var secureToken: () -> String = {
        let token = String(format: "%@", secureSecret)
        NSUserDefaults.standardUserDefaults().setSecret(token)
        return token
    }
    
    func migrateToSecureDefaults() {
        if let storedAgentId = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
            self.agentId = storedAgentId
        }
        if let storedAuthToken = NSUserDefaults.standardUserDefaults().valueForKey("authToken") as? String {
            self.authToken = storedAuthToken
        }
        NSUserDefaults.standardUserDefaults().setSecretBool(true, forKey: "onSecureDefaults")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("authToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func initWithDictionary(dictionary: Dictionary<String, AnyObject>) -> CurrentUser {
        let currentUser = CurrentUser()
        if let authToken = dictionary["authToken"] as? String {
            currentUser.authToken = authToken
        }
        if let permissions = dictionary["permissions"] as? Dictionary<String, AnyObject> {
            currentUser.setPermissionsFromDictionary(permissions)
        }
        if let toggles = dictionary["toggles"] as? Dictionary<String, AnyObject> {
            currentUser.setTogglesFromDictionary(toggles)
        }
        if let brokerFor = dictionary["linkedAccounts"]?["brokerFor"] as? Array<Dictionary<String, AnyObject>> {
            currentUser.setBrokerForFromDictionaries(brokerFor)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        return currentUser
    }
    
    func setBrokerForFromDictionaries(brokerFor: Array<Dictionary<String, AnyObject>>) {
        
    }
    
//    func initFromDefaults() {
//        
//    }
    
    class func signOut() {
        
    }
    
    class func isSignedIn() -> Bool {
        return true
    }
    
    func setTogglesFromDictionary(dictionary: Dictionary<String, AnyObject>) {
        
    }
    
    class func isFeatureEnabled(name: ToggleName) -> Bool {
        return true
    }
    
    func setPermissionsFromDictionary(dictionary: Dictionary<String, AnyObject>) {
        
    }
    
    class func hasPermission(name: PermissionName) -> Bool {
        return true
    }
    
    
    // MARK: Setters
    
//    - (void)setAgentId:(NSString *)agentId {
//    }
//    
//    - (void)setAgentUserName:(NSString *)agentUserName {
//    }
//    
//    - (void)setAuthToken:(NSString *)authToken {
//    }
//    
//    - (void)setAllowedVerfificationTypes:(NSArray *)allowedVerfificationTypes {
//    }
//    
//    - (void)setToggles:(NSDictionary *)toggles {
//    }
//    
//    - (void)setPermissions:(NSDictionary *)permissions {
//    }
//    
//    - (void)setBrokerFor:(NSArray *)brokerFor
//    {
//    }
    
    

    
}
