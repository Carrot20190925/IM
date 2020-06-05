//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalCoreKit

// WARNING: This code is generated. Only edit within the markers.

public enum ProvisioningProtoError: Error {
    case invalidProtobuf(description: String)
}

// MARK: - ProvisioningProtoProvisionEnvelope

@objc public class ProvisioningProtoProvisionEnvelope: NSObject {

    // MARK: - ProvisioningProtoProvisionEnvelopeBuilder

    @objc public class func builder(publicKey: Data, body: Data) -> ProvisioningProtoProvisionEnvelopeBuilder {
        return ProvisioningProtoProvisionEnvelopeBuilder(publicKey: publicKey, body: body)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> ProvisioningProtoProvisionEnvelopeBuilder {
        let builder = ProvisioningProtoProvisionEnvelopeBuilder(publicKey: publicKey, body: body)
        return builder
    }

    @objc public class ProvisioningProtoProvisionEnvelopeBuilder: NSObject {

        private var proto = ProvisioningProtos_ProvisionEnvelope()

        @objc fileprivate override init() {}

        @objc fileprivate init(publicKey: Data, body: Data) {
            super.init()

            setPublicKey(publicKey)
            setBody(body)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPublicKey(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.publicKey = valueParam
        }

        public func setPublicKey(_ valueParam: Data) {
            proto.publicKey = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setBody(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.body = valueParam
        }

        public func setBody(_ valueParam: Data) {
            proto.body = valueParam
        }

        @objc public func build() throws -> ProvisioningProtoProvisionEnvelope {
            return try ProvisioningProtoProvisionEnvelope.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try ProvisioningProtoProvisionEnvelope.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: ProvisioningProtos_ProvisionEnvelope

    @objc public let publicKey: Data

    @objc public let body: Data

    private init(proto: ProvisioningProtos_ProvisionEnvelope,
                 publicKey: Data,
                 body: Data) {
        self.proto = proto
        self.publicKey = publicKey
        self.body = body
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> ProvisioningProtoProvisionEnvelope {
        let proto = try ProvisioningProtos_ProvisionEnvelope(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: ProvisioningProtos_ProvisionEnvelope) throws -> ProvisioningProtoProvisionEnvelope {
        guard proto.hasPublicKey else {
            throw ProvisioningProtoError.invalidProtobuf(description: "\(logTag) missing required field: publicKey")
        }
        let publicKey = proto.publicKey

        guard proto.hasBody else {
            throw ProvisioningProtoError.invalidProtobuf(description: "\(logTag) missing required field: body")
        }
        let body = proto.body

        // MARK: - Begin Validation Logic for ProvisioningProtoProvisionEnvelope -

        // MARK: - End Validation Logic for ProvisioningProtoProvisionEnvelope -

        let result = ProvisioningProtoProvisionEnvelope(proto: proto,
                                                        publicKey: publicKey,
                                                        body: body)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension ProvisioningProtoProvisionEnvelope {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension ProvisioningProtoProvisionEnvelope.ProvisioningProtoProvisionEnvelopeBuilder {
    @objc public func buildIgnoringErrors() -> ProvisioningProtoProvisionEnvelope? {
        return try! self.build()
    }
}

#endif

// MARK: - ProvisioningProtoProvisionMessage

@objc public class ProvisioningProtoProvisionMessage: NSObject {

    // MARK: - ProvisioningProtoProvisionMessageBuilder

    @objc public class func builder(userId: String, provisioningCode: String, userAgent: String) -> ProvisioningProtoProvisionMessageBuilder {
        return ProvisioningProtoProvisionMessageBuilder(userId: userId, provisioningCode: provisioningCode, userAgent: userAgent)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> ProvisioningProtoProvisionMessageBuilder {
        let builder = ProvisioningProtoProvisionMessageBuilder(userId: userId, provisioningCode: provisioningCode, userAgent: userAgent)

        return builder
    }

    @objc public class ProvisioningProtoProvisionMessageBuilder: NSObject {

        private var proto = ProvisioningProtos_ProvisionMessage()

        @objc fileprivate override init() {}

        @objc fileprivate init(userId: String, provisioningCode: String, userAgent: String) {
            super.init()

            setProvisioningCode(provisioningCode)
            setUserAgent(userAgent)
            setUserId(userId)

        }





        @objc
        @available(swift, obsoleted: 1.0)
        public func setProvisioningCode(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.provisioningCode = valueParam
        }

        public func setProvisioningCode(_ valueParam: String) {
            proto.provisioningCode = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setUserAgent(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.userAgent = valueParam
        }

        public func setUserAgent(_ valueParam: String) {
            proto.userAgent = valueParam
        }
        @objc
        @available(swift, obsoleted: 1.0)
        public func setUserId(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.userID = valueParam
        }

        public func setUserId(_ valueParam: String) {
            proto.userID = valueParam
        }



        @objc public func build() throws -> ProvisioningProtoProvisionMessage {
            return try ProvisioningProtoProvisionMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try ProvisioningProtoProvisionMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: ProvisioningProtos_ProvisionMessage


    @objc public let userId: String

    @objc public let provisioningCode: String

    @objc public let userAgent: String



    private init(proto: ProvisioningProtos_ProvisionMessage,
                 userId: String,
                 provisioningCode: String,
                 userAgent: String) {
        self.proto = proto
        self.userId = userId
        self.provisioningCode = provisioningCode
        self.userAgent = userAgent
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> ProvisioningProtoProvisionMessage {
        let proto = try ProvisioningProtos_ProvisionMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: ProvisioningProtos_ProvisionMessage) throws -> ProvisioningProtoProvisionMessage {


        guard proto.hasProvisioningCode else {
            throw ProvisioningProtoError.invalidProtobuf(description: "\(logTag) missing required field: provisioningCode")
        }
        let provisioningCode = proto.provisioningCode

        guard proto.hasUserAgent else {
            throw ProvisioningProtoError.invalidProtobuf(description: "\(logTag) missing required field: userAgent")
        }
        let userAgent = proto.userAgent
        guard proto.hasUserID else {
            throw ProvisioningProtoError.invalidProtobuf(description: "\(logTag) missing required field: userId")
        }
        let userId = proto.userID

        // MARK: - Begin Validation Logic for ProvisioningProtoProvisionMessage -

        // MARK: - End Validation Logic for ProvisioningProtoProvisionMessage -

        let result = ProvisioningProtoProvisionMessage(proto: proto, userId: userId, provisioningCode: provisioningCode, userAgent: userAgent)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension ProvisioningProtoProvisionMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension ProvisioningProtoProvisionMessage.ProvisioningProtoProvisionMessageBuilder {
    @objc public func buildIgnoringErrors() -> ProvisioningProtoProvisionMessage? {
        return try! self.build()
    }
}

#endif
