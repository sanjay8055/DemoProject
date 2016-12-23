#Intro

Provisioning is a really annoying aspect to distributing apps and even developing and testing on devices. This guide has been created to try setup a general "best practice" in reards to handing provisioning ZipID apps.

#AppStore Builds
The general approach here is to use the team wildcard for development and adhoc installations. A central appstore certificate can be shared along with the signing keys.

The main distribution certificate and its corresponding keys and provisioning profiles are included.

##Setup For AppStore
1. Open up "Keychain access" app.
2. Drag over the two keys. If you are asked for a password for the .p12 or .pem files use "zipid"
3. Next drag over the Cert file
4. Open up the two .mobileprovisioning files, this should then install them.
5. Open up the ZipID.workspace file and try creating an archive for the PROD target. It should build through.
6. You should not need to change the Code Signing params if the above is correct.

If you have any issues importing the pem or p12 try these two commands:


	security import ZipID.p12 -k ~/Library/Keychains/!!!!your keychain file!!!!.keychain
	security import ZipID.pem -k ~/Library/Keychains/!!!!your keychain file!!!!.keychain

##AppStore Releases
Appstore releases are straight forward. You will need a developer login to apple developer and iTunes connect account. From there you submit to the app store.

#Enterprise Builds
Enterprise builds are quite the same, however Apple Requires a separate developer account for this. We will continue to use the same signing keys however. The enterprise account is a whole new developer account, for the username and password please check lastpass

##Important!
Do not revoke an active certificate. It will cause existing applications to cease working. Instead let certificates expire after their 3 years and go about migrating to a newer certificate before that happens:

	The OCSP response is cached on the device for the period of time specified by the OCSP server—currently between 3 and 7 days. The validity of the certificate will not be checked again until the device has restarted and the cached response has expired. If a revocation is received at that time, the app will be prevented from running. Revoking a distribution certificate will invalidate all of the applications you have distributed.

##Setup For Enterprise
1. Ensure steps 1 & 2 have been carried out from above
2. Drag over the two enterprise certificates to keychain app
3. Next select the two enterprise provisioning profiles and open then. This will install them.
4. In order to export for an enterprise build you will need to login to the enterprise account via xcode.
5. Go to preferences in xcode, then click on accounts. Add a new Apple ID and login via enterprise@zipid.com.au. The password can be found in lastpass

##Releasing Enterprise Builds
Releasing enterprise builds are a little more tricky than the guided AppStore release flow:

1. Create an archive using the enterprise target in Xcode.
2. Once archived export for enterprise distribution (should be the third option)
3. Once the ipa has been exported upload it to the Amazon S3 Bucket ensuring you do not overwrite the existing ipa (make sure it's named differently).
4. Open up the ZipID website repository and edit the file `site/source/manifest.plist`
5. You will want to update the following line `<string>https://s3-ap-southeast-2.amazonaws.com/zipid-dev/ZipID.ipa</string>` to be whatever you named the .ipa file
6. Next update the version of the app via `bundle-version`
7. Commit your changes and do a production release.
8. Once released and publicly available whenever an enterprise client fires up the app they will be presented with a dialogue to update the application, of which will take them to: `http://zipid.com.au/ios/enterprise/update`

##Releasing via MDM
If a device is registered with mobile device management services for zipid a new build can be pushed to the device. It however may clash with the operations of the above steps if the two versions are not in sync, so please keep timing of these in mind as the above should occur first.

To update via MDM you will need to login to the MDM server `https://iosmgr.zipid.com.au/profilemanager` and upload the new enterprise IPA, then select the group or list of devices you wish to request a pushed update to.