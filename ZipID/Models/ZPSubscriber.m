//
//  ZPSubscriber.m
//  ZipID
//
//  Created by Damien Hill on 15/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZipID-Swift.h"
#import "ZPSubscriber.h"
#import "NSUserDefaults+SecureAdditions.h"
#import "NSDictionary+Nillable.h"

const static NSString *secureSecret = @"3d83bfddc@$43fb!de6#14f6a1b56ee0937438#@$232";

@interface ZPSubscriber()

@property (nonatomic, strong) NSString *secureToken;
@property (nonatomic, retain) NSDictionary *toggles;
@property (nonatomic, retain) NSDictionary *permissions;

@end


@implementation ZPSubscriber

+ (instancetype)sharedInstance {
	static id sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] initFromDefaults];
	});
	
	return sharedInstance;
}

- (NSString *)secureToken {
	NSString *secureToken = [NSString stringWithFormat:@"%@", secureSecret];
	[[NSUserDefaults standardUserDefaults] setSecret:secureToken];
	return secureToken;
}

- (void)migrateToSecureDefaults {
	self.agentId = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
	self.authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
	[[NSUserDefaults standardUserDefaults] setSecretBool:YES forKey:@"onSecureDefaults"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)initWithDictionary:(NSDictionary *)dictionary {
	ZPSubscriber *subscriber = [ZPSubscriber sharedInstance];
	subscriber.authToken = [dictionary validatedValueForKey:@"authToken"];
	
	NSDictionary *permissions = [dictionary validatedValueForKey:@"permissions"];
	[subscriber setPermissionsFromDictionary:permissions];
    
    NSDictionary *toggles = [dictionary validatedValueForKey:@"toggles"];
    [subscriber setTogglesFromDictionary:toggles];
	
    NSDictionary *linkedAccounts = [dictionary validatedValueForKey:@"linkedAccounts"];
    NSArray *brokerFor = [linkedAccounts validatedValueForKey:@"owners"];
    [subscriber setBrokerForFromDictionaries:brokerFor];
    
    NSDictionary *accountDict = [dictionary validatedValueForKey:@"account"];
    [subscriber setAccountFromDictionary:accountDict];
    
	[[NSUserDefaults standardUserDefaults] synchronize];
	return subscriber;
}

- (void)setBrokerForFromDictionaries:(NSArray *)array {
    self.brokerFor = array;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAccountFromDictionary:(NSDictionary *)dictionary {
    Account *account = [[Account alloc] initWithDictionary:dictionary];
    self.account = account;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPermissionsFromDictionary:(NSDictionary *)dictionary {
	self.allowedVerfificationTypes = [dictionary validatedValueForKey:@"verificationTypes"];
    
    self.permissions = dictionary;
    if (![ZPSubscriber hasPermission:PermissionNameTestMode]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"testMode"];
    }
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTogglesFromDictionary:(NSDictionary *)dictionary {
    self.toggles = dictionary;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)initFromDefaults {
	if (self = [super init]) {
		
		[self secureToken];
		if (![[NSUserDefaults standardUserDefaults] secretBoolForKey:@"onSecureDefaults"]) {
			[self migrateToSecureDefaults];
			return self;
		}
        
        self.rememberUsername = [[NSUserDefaults standardUserDefaults] secretBoolForKey:@"secret_rememberUsername"];
		self.agentId = [[NSUserDefaults standardUserDefaults] secretStringForKey:@"secret_username"];
        self.agentUserName = [[NSUserDefaults standardUserDefaults] secretStringForKey:@"secret_agent_username"];
        self.agentFirstName = [[NSUserDefaults standardUserDefaults] secretStringForKey:@"secret_agent_firstName"];
        self.agentLastName = [[NSUserDefaults standardUserDefaults] secretStringForKey:@"secret_agent_lastName"];
        self.authToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:@"secret_authToken"];
		self.allowedVerfificationTypes = [[NSUserDefaults standardUserDefaults] secretObjectForKey:@"secret_allowedVerfificationTypes"];
        self.permissions = [[NSUserDefaults standardUserDefaults] secretObjectForKey:@"secret_permissions"];
        self.toggles = [[NSUserDefaults standardUserDefaults] secretObjectForKey:@"secret_toggles"];
        self.brokerFor = [[NSUserDefaults standardUserDefaults] secretObjectForKey:@"secret_brokerFor"];
        [self setAccountFromDictionary:[[NSUserDefaults standardUserDefaults] secretObjectForKey:@"secret_account"]];
        
		self.lastUsedUsername = [[NSUserDefaults standardUserDefaults] secretStringForKey:@"secret_lastUsedUsername"];
	}
	return self;
}

+ (void)signOut {
    DebugLog(@"Signing out");
    
    [[SEGAnalytics sharedAnalytics] reset];
    
    [[self sharedInstance] setAuthToken:nil];
    [[self sharedInstance] setAgentId:nil];
    [[self sharedInstance] setAgentUserName:nil];
    [[self sharedInstance] setAgentFirstName:nil];
    [[self sharedInstance] setAgentLastName:nil];
    [[self sharedInstance] setAllowedVerfificationTypes:nil];
    [[self sharedInstance] setPermissions:nil];
    [[self sharedInstance] setToggles:nil];
    [[self sharedInstance] setBrokerFor:nil];
    [[self sharedInstance] setAccount:nil];
    
    ZPSubscriber *subscriber = [self sharedInstance];
    if (!subscriber.rememberUsername) {
        subscriber.lastUsedUsername = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_lastUsedUsername"];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_agent_username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_agent_firstName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_agent_lastName"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_authToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_canCreateAdhocJobs"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_canFetchRemoteJobs"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_allowedVerfificationTypes"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_permissions"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_toggles"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_brokerFor"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_account"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastUsedVerificationType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSignOut" object:nil];
    
}

+ (BOOL)isSignedIn {
    ZPSubscriber *subscriber = [ZPSubscriber sharedInstance];
    return subscriber.authToken && subscriber.agentId;
}

+ (BOOL)hasPermission:(PermissionName)name {
    ZPSubscriber *subscriber = [ZPSubscriber sharedInstance];
    if ([subscriber.permissions objectForKey:[NSNumber numberWithInt:name]]) {
        Permission *permission = (Permission *)[subscriber.permissions objectForKey:[NSNumber numberWithInt:name]];
        return permission.enabled;
    } else {
        return NO;
    }
}

+ (BOOL)isFeatureEnabled:(ToggleName)name {
    ZPSubscriber *subscriber = [ZPSubscriber sharedInstance];
    if ([subscriber.toggles objectForKey:[NSNumber numberWithInt:name]]) {
        Toggle *toggle = (Toggle *)[subscriber.toggles objectForKey:[NSNumber numberWithInt:name]];
        return toggle.enabled;
    } else {
        return NO;
    }
}

/* ---- SETTERS ------ */
- (void)setAgentId:(NSString *)agentId {
	_agentId = agentId;
	[[NSUserDefaults standardUserDefaults] setSecretObject:agentId forKey:@"secret_username"];
}

- (void)setAgentUserName:(NSString *)agentUserName {
    _agentUserName = agentUserName;
    [[NSUserDefaults standardUserDefaults] setSecretObject:agentUserName forKey:@"secret_agent_username"];
    if (self.rememberUsername) {
        if (agentUserName) {
            _lastUsedUsername = agentUserName;
            [[NSUserDefaults standardUserDefaults] setSecretObject:agentUserName forKey:@"secret_lastUsedUsername"];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_lastUsedUsername"];
    }
}
- (void)setAgentFirstName:(NSString *)agentFirstName {
    _agentFirstName = agentFirstName;
    [[NSUserDefaults standardUserDefaults] setSecretObject:agentFirstName forKey:@"secret_agent_firstName"];
 }

- (void)setAgentLastName:(NSString *)agentLastName {
    _agentLastName = agentLastName;
    [[NSUserDefaults standardUserDefaults] setSecretObject:agentLastName forKey:@"secret_agent_lastName"];
}

- (void)setAuthToken:(NSString *)authToken {
	_authToken = authToken;
	[[NSUserDefaults standardUserDefaults] setSecretObject:authToken forKey:@"secret_authToken"];
}

- (void)setAllowedVerfificationTypes:(NSArray *)allowedVerfificationTypes {
	_allowedVerfificationTypes = allowedVerfificationTypes;
	[[NSUserDefaults standardUserDefaults] setSecretObject:allowedVerfificationTypes forKey:@"secret_allowedVerfificationTypes"];
}

- (void)setRememberUsername:(BOOL)rememberUsername {
    _rememberUsername = rememberUsername;
    [[NSUserDefaults standardUserDefaults] setSecretBool:rememberUsername forKey:@"secret_rememberUsername"];
}

- (void)setToggles:(NSDictionary *)toggles {
    NSMutableDictionary *togglesMutable = [NSMutableDictionary dictionary];
    for (id key in toggles) {
        ToggleName name = [Toggle toggleNameForString:(NSString *)key];
        if (name != ToggleNameNone) {
            BOOL enabled = [[toggles objectForKey:key] boolValue];
            Toggle *toggle = [[Toggle alloc] initWithName:name enabled:enabled];
            [togglesMutable setObject:toggle forKey:[NSNumber numberWithInt:name]];
        }
    }
    _toggles = [NSDictionary dictionaryWithDictionary:togglesMutable];
    [[NSUserDefaults standardUserDefaults] setSecretObject:toggles forKey:@"secret_toggles"];
}

- (void)setPermissions:(NSDictionary *)permissions {
    NSMutableDictionary *permissionsMutable = [NSMutableDictionary dictionary];
    for (id key in permissions) {
        if ([key isEqualToString:@"verificationTypes"]) continue;
        
        PermissionName name = [Permission permissionNameForString:(NSString *)key];
        if (name != PermissionNameNone) {
            BOOL enabled = [[permissions objectForKey:key] boolValue];
            Permission *permission = [[Permission alloc] initWithName:name enabled:enabled];
            [permissionsMutable setObject:permission forKey:[NSNumber numberWithInt:name]];
        }
    }
    _permissions = [NSDictionary dictionaryWithDictionary:permissionsMutable];
    [[NSUserDefaults standardUserDefaults] setSecretObject:permissions forKey:@"secret_permissions"];
}

- (void)setBrokerFor:(NSArray *)brokerFor
{
    NSMutableArray *mutableBrokerFor = [NSMutableArray array];
    for (NSDictionary *accountDict in brokerFor) {
        Account *account = [[Account alloc] initWithDictionary:accountDict];
        if (account) {
            [mutableBrokerFor addObject:account];
        }
    }
    _brokerFor = [NSArray arrayWithArray:mutableBrokerFor];
    [[NSUserDefaults standardUserDefaults] setSecretObject:brokerFor forKey:@"secret_brokerFor"];
}

- (void)setAccount:(Account *)account
{
    _account = account;
    NSDictionary *accountDict = [_account toDictionary];
    [[NSUserDefaults standardUserDefaults] setSecretObject:accountDict forKey:@"secret_account"];
}

@end
