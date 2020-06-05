//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import PromiseKit.AnyPromise
let OSS_ENDPOINT = "oss-accelerate.aliyuncs.com"
let BucketName = "clientsfiles"
let pigram_sts_config_key = "pigram_sts_config_key"
//let Bucket = textSecureCDNServerURL
class PigramUploadConfig : NSObject {
    static let share = PigramUploadConfig.init()
    var oss_endpoint = OSS_ENDPOINT
    var bucketName = BucketName
    var bucket = textSecureCDNServerURL
    private override init() {
        super.init()
        if let config = UserDefaults.standard.object(forKey: pigram_sts_config_key) as? [String:String] {
            if let oss_endpoint = config["oss_endpoint"]  as String?{
                self.oss_endpoint = oss_endpoint
            }
            if let bucketName = config["bucketName"]  as String?{
                self.bucketName = bucketName
            }
            if let bucket = config["bucket"]  as String?{
                self.bucket = bucket
            }
        }
        //MARK:-  请求最新数据
        PigramNetworkMananger.getOSSConfigRequest(success: {[weak self] (response) in
            if let config = UserDefaults.standard.object(forKey: pigram_sts_config_key) as? [String:String] {
                if let oss_endpoint = config["oss_endpoint"]  as String?{
                    self?.oss_endpoint = oss_endpoint
                }
                if let bucketName = config["bucketName"]  as String?{
                    self?.bucketName = bucketName
                }
                if let bucket = config["bucket"]  as String?{
                    self?.bucket = "https://\(bucket)"
                }
                self?.save()
            }
        }) { (error) in
            
        }
        
        
    }
    
    func save() {
        let config = ["oss_endpoint":self.oss_endpoint,"bucketName":bucketName,"bucket":bucket]
        UserDefaults.standard.set(config, forKey: pigram_sts_config_key)
        UserDefaults.standard.synchronize()
    }
    
    

    
}



class PigramUpload: NSObject {
    static let share = PigramUpload.init()
    var client : OSSClient!
    
    var objectKey : String?
//    let server_url = "https://server.qingrunjiaoyu.com/sts"
    private override init() {
        super.init()
        
        self.setupClient()
        
    }
    
    
    
    func setupClient(){
        OSSLog.enable()
         let credential : OSSCredentialProvider = OSSFederationCredentialProvider.init { () -> OSSFederationToken? in
                 // 构造请求访问您的业务server
             let tcs : OSSTaskCompletionSource = OSSTaskCompletionSource<AnyObject>()

            
             PigramNetworkPromise.getOSSTokenPromise().done { (response) in
                 tcs.setResult(response as AnyObject?)
                MyLog("获取token  成功\(String(describing: response))")
             }.catch { (error) in
                 tcs.setError(error)
                MyLog("获取token 失败\(error)")
             }.retainUntilComplete()
             tcs.task.waitUntilFinished()
             if let _ = tcs.task.error{
                 return nil
             }
             
             if let objc = tcs.task.result as? [String : Any?]{
                 let token = OSSFederationToken.init()
                 if let AccessKeyId = objc["AccessKeyId"] as? String{
                     token.tAccessKey = AccessKeyId
                 }
                 if let AccessKeySecret = objc["AccessKeySecret"] as? String{
                     token.tSecretKey = AccessKeySecret
                 }
                 if let SecurityToken = objc["SecurityToken"] as? String{
                     token.tToken = SecurityToken
                 }
                 if let Expiration = objc["Expiration"] as? String{
                     token.expirationTimeInGMTFormat = Expiration
                 }
                 return token
    
             }
             return nil
         }
        let Uploadconfig = PigramUploadConfig.share
        let config = OSSClientConfiguration.init()
        config.maxRetryCount = 3
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 24 * 60 * 60
        client = OSSClient.init(endpoint: Uploadconfig.oss_endpoint, credentialProvider: credential, clientConfiguration: config)
//        client = OSSClient.init(endpoint: Uploadconfig.oss_endpoint, credentialProvider: credential)
    }
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
        
}

extension OWSAvatarUploadV2 :OWSAttachmentUploadV2Protocol{
    public func uploadFile(_ data: Data, name: String, resovel resolve:@escaping  __PMKResolver, progressBlock: @escaping UploadProgressBlock) {
                let put = OSSPutObjectRequest.init()
        let upload = PigramUploadConfig.share
        put.bucketName = upload.bucketName
        put.objectKey = name
        put.uploadingData = data
        put.uploadProgress = { ( bytesSent : Int64,  totalByteSent : Int64,  totalBytesExpectedToSend : Int64) in
            let progress = Progress.init(totalUnitCount: totalBytesExpectedToSend)
            progress.completedUnitCount = totalByteSent
            MyLog("\(bytesSent) + \(totalByteSent) + \(totalBytesExpectedToSend)" )
            progressBlock(progress)
        }
        
        let putTask = PigramUpload.share.client.putObject(put)
        putTask.continue ({ (t) -> Any? in
            if let error = t.error{
                resolve(error)
            }else{
                resolve(1)
            }
            return nil
        })
        
    }
}

extension OWSAttachmentUploadV2:OWSAttachmentUploadV2Protocol{
    public func uploadFile(_ data: Data, name: String, resovel resolve:@escaping  __PMKResolver, progressBlock: @escaping UploadProgressBlock) {
        let put = OSSPutObjectRequest.init()
        let upload = PigramUploadConfig.share
        put.bucketName = upload.bucketName
        put.objectKey = name
        put.uploadingData = data
        put.uploadProgress = { ( bytesSent : Int64,  totalByteSent : Int64,  totalBytesExpectedToSend : Int64) in
            let progress = Progress.init(totalUnitCount: totalBytesExpectedToSend)
            progress.completedUnitCount = totalByteSent
            MyLog("\(bytesSent) + \(totalByteSent) + \(totalBytesExpectedToSend)" )
            progressBlock(progress)
        }
        
        let putTask = PigramUpload.share.client.putObject(put)
        putTask.continue ({ (t) -> Any? in
            if let error = t.error as NSError?{
                MyLog("上传失败\(error)")
                if error.code == 203{
                    resolve(1)
                }else{
                    resolve(error)
                }
            }else{
                MyLog("成功上传")
                resolve(1)
            }
            return nil
        })
        
    }
    func uploadFile(data : Data,name : String) {


    }
    
}



