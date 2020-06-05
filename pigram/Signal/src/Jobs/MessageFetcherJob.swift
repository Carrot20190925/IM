//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import PromiseKit
import SignalServiceKit

@objc(OWSMessageFetcherJob)
public class MessageFetcherJob: NSObject {

    private var timer: Timer?

    weak private var messagePromise: Promise<Void>?
    @objc
    public override init() {
        super.init()

        SwiftSingletons.register(self)
    }
    
    private var hasMoreMessage: Bool = false;

    // MARK: Singletons

    private var networkManager: TSNetworkManager {
        return SSKEnvironment.shared.networkManager
    }

    private var messageReceiver: OWSMessageReceiver {
        return SSKEnvironment.shared.messageReceiver
    }

    private var signalService: OWSSignalService {
        return OWSSignalService.sharedInstance()
    }

    private var tsAccountManager: TSAccountManager {
        return TSAccountManager.sharedInstance()
    }

    private var firstOfflineEnvelop: SSKProtoEnvelope?
    // MARK: 

    @discardableResult
    public func run() -> Promise<Void> {

        Logger.debug("")
        if self.messagePromise != nil {
            Logger.info("--------------------正在拉去离线消息....");
            return Promise.value(());
        }
        guard tsAccountManager.isRegisteredAndReady else {
            owsFailDebug("isRegisteredAndReady was unexpectedly false")
            return Promise.value(())
        }

//        guard signalService.isCensorshipCircumventionActive else {
//            Logger.debug("delegating message fetching to SocketManager since we're using normal transport.")
//            TSSocketManager.shared.requestSocketOpen()
//            return Promise.value(())
//        }

        Logger.info("fetching messages via REST.")

        let promise = self.fetchUndeliveredMessages().then { (envelopes: [SSKProtoEnvelope], more: Bool) -> Promise<Void> in
            self.hasMoreMessage = more;
            print("离线消息多少条---------\(envelopes.count)");
            self.messagePromise = nil;
            SSKEnvironment.shared.offlineProcessor.pg_handleReceivedEnvelopes(envelopes);
//            for (index,envelope) in envelopes.enumerated() {
//                if index < envelopes.count - 1 {
//                    envelope.isNeedNotify = false;
//                }
//                Logger.info("received envelope by offline.")
//                do {
//                    let envelopeData = try envelope.serializedData()
//                    SSKEnvironment.shared.offlineProcessor.pg_handleReceivedEnvelopeData(envelopeData)
//                } catch {
//                    owsFailDebug("failed to serialize envelope")
//                }
////                self.acknowledgeDelivery(envelope: envelope);
//            }
            if envelopes.count > 0 {

                self.acknowledgeDeliveryAll(envelopes: envelopes);
            }
            
            if !more {
                // All finished
                Logger.info("没有更多离线消息");
//                if let _envelope = self.firstOfflineEnvelop  {
//                    do {
//                        let envelopeData = try _envelope.serializedData()
//                        SSKEnvironment.shared.batchMessageProcessor.pg_handleReceivedEnvelopeData(envelopeData)
//                    } catch {
//                        owsFailDebug("failed to serialize envelope")
//                    }
//                    self.firstOfflineEnvelop = nil;
////                    NotificationCenter.default.post(name: Notification.Name.kNotificaation_Pigram_Offline_Message_Finished, object: nil);
//                }
                
                self.messagePromise = nil;
                return Promise.value(())
            }
            return Promise.value(())
        }
        promise.catch { (error) in
            self.messagePromise = nil;
        }
        promise.retainUntilComplete()
        self.messagePromise = promise;
        return promise
    }
    
    @discardableResult
    private func rerun() -> Promise<Void> {
        return self.run();
    }

    @objc
    @discardableResult
    public func run() -> AnyPromise {
        return AnyPromise(run() as Promise)
    }

    // use in DEBUG or wherever you can't receive push notifications to poll for messages.
    // Do not use in production.
    public func startRunLoop(timeInterval: Double) {
        Logger.error("Starting message fetch polling. This should not be used in production.")
        timer = WeakTimer.scheduledTimer(timeInterval: timeInterval, target: self, userInfo: nil, repeats: true) {[weak self] _ in
            let _: Promise<Void>? = self?.run()
            return
        }
    }

    public func stopRunLoop() {
        timer?.invalidate()
        timer = nil
    }

    private func parseMessagesResponse(responseObject: Any?) -> (envelopes: [SSKProtoEnvelope], more: Bool)? {
        guard let responseObject = responseObject else {
            Logger.error("response object was surpringly nil")
            return nil
        }

        guard let responseDict = responseObject as? [String: Any] else {
            Logger.error("response object was not a dictionary")
            return nil
        }

        guard let messageDicts = responseDict["messages"] as? [[String: Any]] else {
            Logger.error("messages object was not a list of dictionaries")
            return nil
        }

        let moreMessages = { () -> Bool in
            if let responseMore = responseDict["more"] as? Bool {
                return responseMore
            } else {
                Logger.warn("more object was not a bool. Assuming no more")
                return false
            }
        }()

        let envelopes: [SSKProtoEnvelope] = messageDicts.compactMap { buildEnvelope(messageDict: $0) }

        return (
            envelopes: envelopes,
            more: moreMessages
        )
    }

    private func buildEnvelope(messageDict: [String: Any]) -> SSKProtoEnvelope? {
        do {
            let params = ParamParser(dictionary: messageDict)

            let typeInt: Int32 = try params.required(key: "type")
            guard let type: SSKProtoEnvelope.SSKProtoEnvelopeType = SSKProtoEnvelope.SSKProtoEnvelopeType(rawValue: typeInt) else {
                Logger.error("`type` was invalid: \(typeInt)")
                throw ParamParser.ParseError.invalidFormat("type")
            }

            guard let timestamp: UInt64 = try params.required(key: "timestamp") else {
                Logger.error("`timestamp` was invalid: \(typeInt)")
                throw ParamParser.ParseError.invalidFormat("timestamp")
            }

            let builder = SSKProtoEnvelope.builder(timestamp: timestamp)
            builder.setType(type)

            if let source: String = try params.optional(key: "source") {
                builder.setSourceId(source)
            }
            
            if let sourceName: String = try params.optional(key: "sourceName") {
                builder.setSourceName(sourceName)
            }
            
            if let sourceAvatar: String = try params.optional(key: "sourceAvatar") {
                builder.setSourceAvatar(sourceAvatar);
            }
            
            if let groupSource: String = try params.optional(key: "groupSource") {
                builder.setRealSource(groupSource);
            }
            
            if let groupSourceName: String = try params.optional(key: "groupSourceName") {
                builder.setRealName(groupSourceName)
            }
            
            if let groupSourceAvatar: String = try params.optional(key: "groupSourceAvatar") {
                builder.setRealAvatar(groupSourceAvatar);
            }

            if let sourceDevice: UInt32 = try params.optional(key: "sourceDevice") {
                builder.setSourceDevice(sourceDevice)
            }

            if let content = try params.optionalBase64EncodedData(key: "content") {
                builder.setContent(content)
            }
            
            if let serverTimestamp: UInt64 = try params.optional(key: "serverTimestamp") {
                builder.setServerTimestamp(serverTimestamp)
            }
            
            
            if let serverGuid: String = try params.optional(key: "guid") {
                builder.setServerGuid(serverGuid)
            }

            return try builder.build()
        } catch {
            owsFailDebug("error building envelope: \(error)")
            return nil
        }
    }

    private func fetchUndeliveredMessages() -> Promise<(envelopes: [SSKProtoEnvelope], more: Bool)> {
        return Promise { resolver in
            let request = OWSRequestFactory.getMessagesRequest()
            self.networkManager.makeRequest(
                request,
                success: { (_: URLSessionDataTask?, responseObject: Any?) -> Void in
                    guard let (envelopes, more) = self.parseMessagesResponse(responseObject: responseObject) else {
                        Logger.error("response object had unexpected content")
                        return resolver.reject(OWSErrorMakeUnableToProcessServerResponseError())
                    }

                    resolver.fulfill((envelopes: envelopes, more: more))
                },
                failure: { (_: URLSessionDataTask?, error: Error?) in
                    guard let error = error else {
                        Logger.error("error was surpringly nil. sheesh rough day.")
                        return resolver.reject(OWSErrorMakeUnableToProcessServerResponseError())
                    }

                    resolver.reject(error)
            })
        }
    }
    private func acknowledgeDeliveryAll(envelopes: [SSKProtoEnvelope]){
        
        let request: TSRequest = OWSRequestFactory.acknowledgeMessagesDeliveryRequest(with: envelopes);
        self.networkManager.makeRequest(request,
                                        success: { (_: URLSessionDataTask?, _: Any?) -> Void in
                                            //所有回执 发送成功后  再拉下一页
                                            if self.hasMoreMessage {
                                                Logger.info("fetching more messages.")
                                                self.messagePromise = nil;
                                                self.rerun();
                                            }
                                           
        },
                                        failure: { (_: URLSessionDataTask?, error: Error?) in
                                            if self.hasMoreMessage {
                                                self.messagePromise = nil;
                                            }
                                            Logger.debug("acknowledging delivery for message at timestamp: \(envelopes.count) failed with error: \(String(describing: error))")
        })
        
        
    }

    private func acknowledgeDelivery(envelope: SSKProtoEnvelope) {
        let request: TSRequest
        if let serverGuid = envelope.serverGuid, serverGuid.count > 0 {
            request = OWSRequestFactory.acknowledgeMessageDeliveryRequest(withServerGuid: serverGuid)
        } else if let sourceAddress = envelope.sourceAddress, sourceAddress.isValid, envelope.timestamp > 0 {
            request = OWSRequestFactory.acknowledgeMessageDeliveryRequest(with: sourceAddress, timestamp: envelope.timestamp)
        } else {
            owsFailDebug("Cannot ACK message which has neither source, nor server GUID and timestamp.")
            return
        }

        self.networkManager.makeRequest(request,
                                        success: { (_: URLSessionDataTask?, _: Any?) -> Void in
                                            Logger.debug("acknowledged delivery for message at timestamp: \(envelope.timestamp)")
        },
                                        failure: { (_: URLSessionDataTask?, error: Error?) in
                                            Logger.debug("acknowledging delivery for message at timestamp: \(envelope.timestamp) failed with error: \(String(describing: error))")
        })
    }
}
