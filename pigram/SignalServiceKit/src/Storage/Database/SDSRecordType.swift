//
//  Copyright © 2019 Signal. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

@objc
public enum SDSRecordType: UInt {
    case baseModel = 56
    case experienceUpgrade = 55
    case installedSticker = 24
    case knownStickerPack = 29
    case _100RemoveTSRecipientsMigration = 40
    case _101ExistingUsersBlockOnIdentityChange = 43
    case _102MoveLoggingPreferenceToUserDefaults = 47
    case _103EnableVideoCalling = 42
    case _104CreateRecipientIdentities = 45
    case _105AttachmentFilePaths = 44
    case _107LegacySounds = 50
    case _108CallLoggingPreference = 48
    case _109OutgoingMessageState = 51
    case addToContactsOfferMessage = 25
    case addToProfileWhitelistOfferMessage = 7
    case backupFragment = 32
    case broadcastMediaMessageJobRecord = 58
    case contactOffersInteraction = 22
    case contactQuery = 57
    case databaseMigration = 46
    case device = 33
    case disappearingConfigurationUpdateInfoMessage = 28
    case disappearingMessagesConfiguration = 39
    case linkedDeviceReadReceipt = 36
    case messageContentJob = 15
    case messageDecryptJob = 8
    case recipientIdentity = 38
    case resaveCollectionDBMigration = 49
    case sessionResetJobRecord = 52
    case unknownContactBlockOfferMessage = 5
    case unknownDBObject = 37
    case unknownProtocolVersionMessage = 54
    case userProfile = 41
    case verificationStateChangeMessage = 13
    case pigramGroupModel = 59
    case jobRecord = 34
    case messageDecryptJobRecord = 53
    case messageSenderJobRecord = 35
    case signalAccount = 30
    case signalRecipient = 31
    case stickerPack = 14
    case attachment = 6
    case attachmentPointer = 3
    case attachmentStream = 18
    case call = 20
    case contactThread = 27
    case errorMessage = 9
    case groupThread = 26
    case incomingMessage = 19
    case infoMessage = 10
    case interaction = 16
    case invalidIdentityKeyErrorMessage = 17
    case invalidIdentityKeyReceivingErrorMessage = 1
    case invalidIdentityKeySendingErrorMessage = 23
    case message = 11
    case outgoingMessage = 21
    case recipientReadReceipt = 12
    case thread = 2
    case unreadIndicatorInteraction = 4
    case messageDecryptOfflineJob = 60
}
