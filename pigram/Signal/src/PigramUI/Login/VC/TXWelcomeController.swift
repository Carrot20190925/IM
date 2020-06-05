//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
//import SnapKit
class TXWelcomeController: TXBaseController {
    var logoImageView = UIImageView.init()
    var loginBtn = UIButton.init()
    var registerBtn = UIButton.init()
    var backImageView = UIImageView.init()
    var avPlay : AVPlayer!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let nav = self.navigationController else {
            return
        }
        if (!nav.navigationBar.isHidden) {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    @objc
    func beginPlay(noti:Notification)  {
        avPlay.currentItem?.seek(to: CMTime.zero)
        avPlay.play()
    }
    private func setupUI(){
        self.view.backgroundColor = UIColor.white;
       let path = Bundle.main.path(forResource: "pigram_welcome.mp4", ofType: nil) ?? ""
       let url = URL.init(fileURLWithPath: path)
       avPlay = AVPlayer.init(url: url)
       NotificationCenter.default.addObserver(self, selector: #selector(beginPlay), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlay.currentItem)
       let avPlayLayer = AVPlayerLayer.init(player: avPlay)
       avPlayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
       avPlayLayer.frame = self.view.bounds
       backImageView.frame = self.view.bounds
        backImageView.image = UIImage.init(named: "pg_laugh_image");
        backImageView.contentMode = .scaleAspectFill;
       backImageView.layer.addSublayer(avPlayLayer)
       avPlay.play()
       loginBtn.setTitle(kPigramLocalizeString("登录", "登录"), for: .normal)
       registerBtn.setTitle(kPigramLocalizeString("注册", "注册"), for: .normal)
       loginBtn.setTitleColor(TXTheme.whiteColor(), for: .normal)
       registerBtn.setTitleColor(TXTheme.whiteColor(), for: .normal)
       loginBtn.backgroundColor = TXTheme.secondColor()
       registerBtn.backgroundColor = TXTheme.secondColor()
       var width = CGFloat.init(60)
       var height = width
        var x = (self.view.width() - width)*0.5;
       var y = CGFloat.init(50.0)
       
       logoImageView.frame = CGRect.init(x: x, y:y, width: width, height: height)
       logoImageView.image = UIImage.init(named: "pigram-logo")
       width = (self.view.width() - 24.0 - 27.0)*0.5
       x = 12
       height = width * 36.0/166.0
       y = self.view.height() - height - 27.0
       if UIDevice.current.hasIPhoneXNotch {
           y -= 30.0
       }
       loginBtn.frame = CGRect.init(x: x, y: y, width: width, height: height)
       x += (width + 27)
       registerBtn.frame = CGRect.init(x: x, y: y, width: width, height: height)
       loginBtn.layer.cornerRadius = height * 0.5
       loginBtn.clipsToBounds = true
       registerBtn.layer.cornerRadius = height * 0.5
       registerBtn.clipsToBounds = true
      
       self.view.addSubview(backImageView)
       self.view.addSubview(logoImageView)
       self.view.addSubview(loginBtn)
       self.view.addSubview(registerBtn)
        logoImageView.mas_makeConstraints {[weak self] (make) in
            make?.centerX.mas_equalTo()(self?.view.mas_centerX)
            make?.centerY.mas_equalTo()(self?.view.mas_centerY)?.offset()(-50);
        }
       loginBtn.addTarget(self, action: #selector(loginAction), for: UIControl.Event.touchUpInside)
       registerBtn.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.avPlay.pause()
    }
    @objc func loginAction(){
        self.onboardingController.loginController(viewController: self)
    }
    @objc func registerAction(){
        self.onboardingController.registerController(viewController: self)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
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
