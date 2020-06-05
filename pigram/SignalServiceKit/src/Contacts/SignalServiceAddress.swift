//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation


@objc
public enum SignalServiceAddressType: Int {
    case unknow   = 0;
    case personal = 1;
    case group    = 2;
}

@objc
public class SignalServiceAddress: NSObject, NSCopying, NSSecureCoding {
    public static let supportsSecureCoding: Bool = true

    private static var cache: SignalServiceAddressCache {
        return SSKEnvironment.shared.signalServiceAddressCache
    }

    @objc
    public var type: SignalServiceAddressType {
        
        get {
            if let _value = self.phoneNumber {
                
                if _value.hasPrefix("___user____") {
                    return .personal;
                } else if _value.hasPrefix("___group___") {
                    return .group;
                } else {
                    return .unknow;
                }
            }
            return .unknow;
        }
    }
    
    @objc
    public var groupid: String? {
        
        get {
            return self.phoneNumber;
        }
    }
    
    @objc
    public var userid: String? {
        
        get {
            return self.phoneNumber;
        }
    }
    /**
     * 添加一个useid  改动太多 现在用phonenumber 表示userid
     */
    private(set) var backingPhoneNumber: String?
    @objc public var phoneNumber: String? {
        guard let phoneNumber = backingPhoneNumber else {
            // If we weren't initialized with a phone number, but the phone number exists in the cache, use it
            guard let uuid = backingUuid,
                let cachedPhoneNumber = SignalServiceAddress.cache.phoneNumber(forUuid: uuid)
            else {
                return nil
            }
            backingPhoneNumber = cachedPhoneNumber
            return cachedPhoneNumber
        }

        return phoneNumber
    }

    // TODO UUID: eventually this can be not optional
    private(set) var backingUuid: UUID?
    @objc public var uuid: UUID? {
        guard let uuid = backingUuid else {
            // If we weren't initialized with a uuid, but the uuid exists in the cache, use it
            guard let phoneNumber = backingPhoneNumber,
                let cachedUuid = SignalServiceAddress.cache.uuid(forPhoneNumber: phoneNumber)
            else {
                return nil
            }
            backingUuid = cachedUuid
            return cachedUuid
        }

        return uuid
    }
//    @objc
//    public var userid: String?

    @objc
    public var uuidString: String? {
        return uuid?.uuidString
    }

    // MARK: - Initializers

//    @objc
//    public convenience init(uuidString: String) {
//        self.init(uuidString: uuidString, phoneNumber: nil)
//    }
//
    @objc
    public convenience init(phoneNumber: String?) {
        self.init(uuidString: nil, phoneNumber: phoneNumber)
    }

    @objc
    public init(uuid: UUID?, phoneNumber: String?) {
        if phoneNumber == nil, let uuid = uuid,
            let cachedPhoneNumber = SignalServiceAddress.cache.phoneNumber(forUuid: uuid) {
            backingPhoneNumber = cachedPhoneNumber
        } else {
            if let phoneNumber = phoneNumber, phoneNumber.isEmpty {
                owsFailDebug("Unexpectedly initialized signal service address with invalid phone number")
            }

            backingPhoneNumber = phoneNumber
        }

        if uuid == nil, let phoneNumber = phoneNumber,
            let cachedUuid = SignalServiceAddress.cache.uuid(forPhoneNumber: phoneNumber) {
            backingUuid = cachedUuid
        } else {
            backingUuid = uuid
        }

        backingHashValue = SignalServiceAddress.cache.hashAndCache(uuid: backingUuid, phoneNumber: backingPhoneNumber)

        super.init()

        if !isValid {
//            owsFailDebug("Unexpectedly initialized address with no identifier")
        }
    }

    @objc
    public convenience init(uuidString: String?, phoneNumber: String?) {
        let uuid: UUID?

        if let uuidString = uuidString {
            uuid = UUID(uuidString: uuidString)
            if uuid == nil {
                owsFailDebug("Unexpectedly initialized signal service address with invalid uuid")
            }
        } else {
            uuid = nil
        }

        self.init(uuid: uuid, phoneNumber: phoneNumber)
    }
//    @objc
//    public convenience init(userid: String?, phoneNumber: String?) {
//        if let phoneNumber = phoneNumber, phoneNumber.isEmpty {
//            owsFailDebug("Unexpectedly initialized signal service address with invalid phone number")
//        }
//        self.init(uuid: nil, phoneNumber: phoneNumber)
//        self.userid = userid;
//
//
//    }
//    @objc
//    public convenience init(userid: String?) {
//
//        self.init(userid: userid, phoneNumber: nil)
//
//
//    }
    // MARK: -

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(backingUuid, forKey: "backingUuid")
        aCoder.encode(backingPhoneNumber, forKey: "backingPhoneNumber")
//        aCoder.encode(self.userid, forKey: "backingUserid")
    }

    public required init?(coder aDecoder: NSCoder) {
        backingUuid = (aDecoder.decodeObject(of: NSUUID.self, forKey: "backingUuid") as UUID?)
        backingPhoneNumber = (aDecoder.decodeObject(of: NSString.self, forKey: "backingPhoneNumber") as String?)
//        userid = (aDecoder.decodeObject(of: NSString.self, forKey: "backingUserid") as String?)

        backingHashValue = SignalServiceAddress.cache.hashAndCache(uuid: backingUuid, phoneNumber: backingPhoneNumber)
    }

    // MARK: -

    @objc
    public func copy(with zone: NSZone? = nil) -> Any {
        let address = SignalServiceAddress(uuid: uuid, phoneNumber: phoneNumber);
//        address.userid = self.userid;
        return address;
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherAddress = object as? SignalServiceAddress else {
            return false
        }

        return isEqualToAddress(otherAddress)
    }

    @objc
    public func isEqualToAddress(_ otherAddress: SignalServiceAddress?) -> Bool {
        guard let otherAddress = otherAddress else {
            return false
        }

        return otherAddress.phoneNumber == phoneNumber && otherAddress.uuid == uuid //&& otherAddress.userid == userid
    }

    // In order to maintain a consistent hash, we use a constant value generated
    // by the cache that can be mapped back to the phone number OR the UUID.
    //
    // This allows us to dynamically update the backing values to maintain
    // the most complete address object as we learn phone <-> UUID mapping,
    // while also allowing addresses to live in hash tables.
    private let backingHashValue: Int
    public override var hash: Int { return backingHashValue }

    @objc
    public func compare(_ otherAddress: SignalServiceAddress) -> ComparisonResult {
        return stringForDisplay.compare(otherAddress.stringForDisplay)
    }

    // MARK: -

    @objc
    public var isValid: Bool {
        
        return (phoneNumber?.count ?? 0 > 0) || self.uuidString?.count ?? 0 > 0
    }

    @objc
    public var isLocalAddress: Bool {
        return TSAccountManager.localAddress == self
    }

    @objc
    public var stringForDisplay: String {
        //hansen  不显示电话号码
        if let phoneNumber = phoneNumber {
            return phoneNumber
        }
//        if let userid = self.userid {
//            return userid
//        }
        if let uuid = uuid {
            return uuid.uuidString
        }
        
        owsFailDebug("unexpectedly have no backing value")

        return ""
    }
    //存储图片使用
     @objc
        public var stringForImageCacheKey: String {
            //hansen  不显示电话号码
            if let phoneNumber = phoneNumber {
                return phoneNumber
            } else
                if let uuid = uuid {
                return uuid.uuidString
            }
            return ""
        }

    /**
     * 不是电话号码就是userid
     *
     */
    @objc
    public var serviceIdentifier: String? {
        
         
        guard let uuid = self.phoneNumber else {
            owsFailDebug("phoneNumber was unexpectedly nil")
            return uuidString
        }
        return uuid
        
    }

    @objc
    override public var description: String {

        return "<SignalServiceAddress phoneNumber: \(phoneNumber ?? "nil"), uuid: \(self.uuidString ?? "nil")>"
    }
}

@objc
public class SignalServiceAddressCache: NSObject {
    private let serialQueue = DispatchQueue(label: "SignalServiceAddressCache")

    private var uuidToPhoneNumberCache = [UUID: String]()
    private var phoneNumberToUUIDCache = [String: UUID]()

    private var uuidToHashValueCache = [UUID: Int]()
    private var phoneNumberToHashValueCache = [String: Int]()

    override init() {
        super.init()
        AppReadiness.runNowOrWhenAppWillBecomeReady { [weak self] in
            SDSDatabaseStorage.shared.asyncRead { transaction in
                SignalRecipient.anyEnumerate(transaction: transaction) { recipient, _ in
                    let recipientUuid: UUID?
                    if let uuidString = recipient.recipientUUID {
                        recipientUuid = UUID(uuidString: uuidString)
                    } else {
                        recipientUuid = nil
                    }
                    self?.hashAndCache(uuid: recipientUuid, phoneNumber: recipient.recipientPhoneNumber)
                }
            }
        }
    }

    /// Adds a uuid <-> phone number mapping to the cache (if necessary)
    /// and returns a constant hash value that can be used to represent
    /// either of these values going forward for the lifetime of the cache.
    @discardableResult
    func hashAndCache(uuid: UUID?, phoneNumber: String?) -> Int {
        return serialQueue.sync {
            // If we have a UUID and a phone number, cache the mapping.
            if let uuid = uuid, let phoneNumber = phoneNumber {
                uuidToPhoneNumberCache[uuid] = phoneNumber
                phoneNumberToUUIDCache[phoneNumber] = uuid
            }

            // Generate or fetch the unique hash value for this address.

            let hash: Int

            // If we already have a hash for the UUID, use it.
            if let uuid = uuid, let uuidHash = uuidToHashValueCache[uuid] {
                hash = uuidHash

            // Otherwise, if we already have a hash for the phone number, use it.
            } else if let phoneNumber = phoneNumber, let phoneNumberHash = phoneNumberToHashValueCache[phoneNumber] {
                hash = phoneNumberHash

            // Else, create a fresh hash that will be used going forward.
            } else {
                hash = UUID().hashValue
            }

            // Cache the hash we're using to ensure it remains constant across future addresses.

            if let phoneNumber = phoneNumber {
                phoneNumberToHashValueCache[phoneNumber] = hash
            }

            if let uuid = uuid {
                uuidToHashValueCache[uuid] = hash
            }

            return hash
        }
    }

    func uuid(forPhoneNumber phoneNumber: String) -> UUID? {
        return serialQueue.sync { phoneNumberToUUIDCache[phoneNumber] }
    }

    func phoneNumber(forUuid uuid: UUID) -> String? {
        return serialQueue.sync { uuidToPhoneNumberCache[uuid] }
    }
}
