
require("UITextField, UIView, UITouch, UIEvent,MASConstraintMaker, Masonry");

defineClass("Signal.TXVerificationCodeController", {
            
            viewDidLoad: function () {
//            self.super().viewDidLoad();
            self.ORIGviewDidLoad();
           
                        self.codeTextField().mas__makeConstraints(block('MASConstraintMaker *', function (make) {

                                                           make.height().offset()(40);
                                                           make.width().equalTo()(self.view());
                                                           }))
            }
            
            
            touchesBegan: function(touches, event) {

                for touch in touches {
                    var point = touche.locationInView(self.view());
                                  var filedpoint = self.view().convertPoint_toView(point!, self.codeTextField());
                                  if (CGRectContainsPoint(self.codeTextField().bounds(),filedpoint) {
                                      self.codeTextField().becomeFirstResponder();
                                  } else {
                                      self.codeTextField().endEditing(true);
                                  }
                                      break;
                }
                  
            }
            
            
            })

