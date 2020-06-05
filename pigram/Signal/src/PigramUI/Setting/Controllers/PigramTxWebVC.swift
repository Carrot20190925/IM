//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import WebKit
class PigramTxWebVC: BaseVC {
    var show = false
    var urlString:String?
    let webView = WKWebView.init(frame: UIScreen.main.bounds)
    var loadDataFinish : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pigram条款和隐私政策"
        guard let urlString = urlString else {
            show = true
            return
        }
        guard let url = URL.init(string: urlString) else {
            show = true
            return
        }
        self.setupWebView(url:url)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !show {
            ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) {[weak self] (model) in
                self?.loadDataFinish = {
                    DispatchQueue.main.async {
                        model.dismiss {
                            
                        }
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
extension PigramTxWebVC : WKNavigationDelegate{
    func setupWebView(url:URL) {
        let request = URLRequest.init(url: url)
        webView.load(request)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let  title = webView.title,title.length != 0 {
            self.title = webView.title
        }
        show = true
        self.loadDataFinish?()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        show = true
        self.loadDataFinish?()
        
    }
    

}
