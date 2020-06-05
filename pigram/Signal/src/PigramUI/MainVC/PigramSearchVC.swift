//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PigramSearchVC: BaseVC {

    
    var placeholderText: String = "请输入...";
    /**
     * 点击了搜索
     */
    var selectedSearchBtnCallback: ((_ tableView: DYTableView?,_ searchText: String) -> (Void))?
    var tableView: DYTableView = {
        
        let view = DYTableView.init();
        view.isShowNoData = false;
        return view;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = self.searchBar;
        self.searchBar.placeholder = self.placeholderText;
        self.searchBar.delegate = self;
        self.view.addSubview(self.tableView);
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        // Do any additional setup after loading the view.
    }
    

    var searchBar: UISearchBar = {
        
        let view = OWSSearchBar.init();
        OWSSearchBar.applyTheme(to: view)
//        view.textField?.clearButtonMode = .whileEditing;
        view.showsCancelButton = true;
//        view.textField?.font = UIFont.systemFont(ofSize: 14);
        return view;
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PigramSearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if self.selectedSearchBtnCallback != nil {
            self.selectedSearchBtnCallback!(self.tableView, searchBar.text ?? "");
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true);
    }
}
