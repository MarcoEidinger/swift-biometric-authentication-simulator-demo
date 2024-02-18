import Foundation
import LocalAuthentication

enum TestData {
    static var kSecAttrAccountValue = "someKey"

    static func deleteFromKeychain() {
        let keychainQuery = NSMutableDictionary(
            objects: [kSecClassGenericPassword as NSString, kSecAttrAccountValue],
            forKeys: [kSecClass as NSString, kSecAttrAccount as NSString]
        )

        SecItemDelete(keychainQuery)
    }

    static func insertIntoKeychain(data: Data) -> Bool {
        var keychainQuery: [String: AnyObject] = [String: NSObject]()
        keychainQuery[kSecClass as String] = kSecClassGenericPassword
        keychainQuery[kSecAttrAccount as String] = kSecAttrAccountValue as NSObject
        keychainQuery[kSecValueData as String] = data as NSObject

        let secAAC = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlocked,
            .biometryAny,
            nil
        )
        keychainQuery[kSecAttrAccessControl as String] = secAAC

        let result = SecItemAdd(keychainQuery as CFDictionary, nil)
        return result == noErr
    }

    static func readFromKeychain(context: LAContext = LAContext()) -> Data? {
        var keychainQuery = [String: NSObject]()

        keychainQuery[kSecClass as String] = kSecClassGenericPassword
        keychainQuery[kSecAttrAccount as String] = kSecAttrAccountValue as NSObject
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecReturnData as String] = kCFBooleanTrue

        if context.localizedReason.isEmpty {
            context.localizedReason = "Authorization needed"
        }
        keychainQuery[kSecUseAuthenticationContext as String] = context as NSObject

        var resultValue: AnyObject?
        let result = withUnsafeMutablePointer(to: &resultValue) {
            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
        }

        guard result == noErr, let data = resultValue as? Data else {
            return nil
        }

        return data
    }
}
