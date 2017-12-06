//
//  HLAuthCitySelectVC.swift
//  HLCreditV2
//
//  Created by HuanLeiMac on 2017/8/2.
//  Copyright © 2017年 VisionMicrocreditCo. All rights reserved.
//

import UIKit

// called after select complete
fileprivate typealias HLAuthEmergencyMobileListCompleteClosure = (_ model: HLAddressBookModel?) -> Void
fileprivate let kHLAuthEmergencyMobileListCell = "HLAuthEmergencyMobileListCell"
let kScreenWidth = UIScreen.main.bounds.width

class HLAuthEmergencyMobileListVC: UIViewController{
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bottomActionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fakeSearchBarBtn: UIButton!
    
    // secondTableView
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var secondSearchBarCancelBtn: UIButton!
    @IBOutlet weak var secondSearchBarTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    
    
    //MARK: iVar
    
    var filteredDataArrays = NSMutableArray()
    
    var dataArrays = NSMutableArray()
    var sectionTitleArr = NSMutableArray()
    var originalAddressData = NSMutableArray()
    
    
    private var isMobileSelected:Bool = false {
        didSet(newValue){
            DispatchQueue.main.async {
                self.confirmBtn.backgroundColor = newValue ? UIColor.orange : UIColor.lightGray
                self.confirmBtn.isEnabled = newValue
            }
        }
    }
    
    fileprivate var selectCompleteClosure:HLAuthEmergencyMobileListCompleteClosure? = nil
    fileprivate var didSelectedMobileClosure:((_ mobile:String) -> Void)? = nil
    
    //MARK: - lifeCycle
    override func viewDidLoad(){
        super.viewDidLoad()
        self.config()
        self.configUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    //MARK: - interface
    
    
    /// 配置已选中的电话
    ///
    /// - Parameter mobile:
    func configSelectedMobile(mobile:String,selectedClosure:((_ mobile:String)->Void)) -> Void {
        
    }
    
    //MARK: - event
    @IBAction func confimBtnPressed(_ sender: UIButton) {
        print("")
        
    }
    
    @IBAction func fakeSearchBarBtnPressed(_ sender: UIButton) {
        print("")
        self.hideSearchPanel(hidden: false)
    }
    @IBAction func searchCancelBtnPressed(_ sender: UIButton) {
        print("")
        
        self.hideSearchPanel(hidden: true)
        
    }
    
    //MARK: - private
    
    func doAfterNormalCellSelected(cell:HLAuthEmergencyMobileListCell) -> Void {
        self.deselectAllModelSource()
        cell.updateModelSelected(selected: true)
        
        self.isMobileSelected = true
        self.tableView.reloadData()
        
        
        print("\(describing: cell.model?.name)\t\( cell.model?.mobile)")
        guard let aClosure = self.selectCompleteClosure else { return  }
        aClosure(cell.model)

    }
    
    func doAfterSearchCellSelected(cell:HLAuthEmergencyMobileListCell) -> Void {
        self.deselectAllModelSource()
        cell.updateModelSelected(selected: true)
        self.isMobileSelected = true
        self.searchTableView.reloadData()
        print("\(describing: cell.model?.name)\t\( cell.model?.mobile)")
        guard let aClosure = self.selectCompleteClosure else { return  }
        aClosure(cell.model)
        
    }
    
    func deselectAllModelSource() -> Void {
        // 正常显示的数据
        for items in self.dataArrays{
            let tmpArr = items as! NSArray
            for item in tmpArr{
                let tmpModel = item as! HLAddressBookModel
                tmpModel.isSelected = false
            }
        }
        
        // 搜索显示的数据
        for item in self.filteredDataArrays{
            let tmpModel = item as! HLAddressBookModel
            tmpModel.isSelected = false
        }
        
        // 原始数据
        for item  in self.originalAddressData {
            let tmpModel = item as! HLAddressBookModel
            tmpModel.isSelected = false
        }
    }
    
    /// 显示或隐藏搜索视图
    ///
    /// - Parameter hidden: 是否隐藏
    func hideSearchPanel(hidden:Bool) -> Void {
        
        let alpha:CGFloat = hidden ? 0.0 : 1.0
        if hidden{
            UIView.animate(withDuration: 0.25, animations: {
                
                self.hideCustomNaviView(hidden: !hidden)
                self.searchContainerView.alpha = alpha
            }, completion: { (finish) in
                self.doAfterSearchPanelAnimated(hidden: hidden)
                
            })
            
        }
        else{
            UIView.animate(withDuration: 0.25, animations: {
                self.searchContainerView.alpha = alpha

            }) { (finish) in
                self.hideCustomNaviView(hidden: !hidden)
                self.doAfterSearchPanelAnimated(hidden: hidden)
            }
        }
    }
    
    func doAfterSearchPanelAnimated(hidden:Bool) -> Void {
        self.isMobileSelected = false
        if hidden{
            self.secondSearchBarTextField.text = nil
            
            self.deselectAllModelSource()
            self.filteredDataArrays.removeAllObjects()
            self.searchTableView.reloadData()
            self.tableView.reloadData()
            
            // 关闭键盘
            self.secondSearchBarTextField.resignFirstResponder()
        }
        else{
            if self.secondSearchBarTextField.canBecomeFirstResponder{
                self.secondSearchBarTextField.becomeFirstResponder()
            }
        }
    }
    
    func hideCustomNaviView(hidden:Bool) -> Void {
        self.navigationController?.setNavigationBarHidden(hidden, animated: true)
    }
    
    func config() -> Void{
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        
        self.isMobileSelected = false
        self.secondSearchBarTextField.addTarget(self, action: #selector(searchTextDidChanged(textField:)), for: UIControlEvents.editingChanged)
        //self.secondSearchBarTextField.addTarget(self, action: #selector(searchTextDidChanged(textField:)), for: UIControlEvents.editingChanged)
        self.requestData()
    }
    
    @objc func searchTextDidChanged(textField:UITextField) -> Void {
        let searchStr = textField.text ?? ""
        self.filterContentForSearchText(searchText: searchStr)

    }
    
    func configUI() -> Void {
        
        self.tableView.tableFooterView = UIView()
        let nib = UINib(nibName: kHLAuthEmergencyMobileListCell, bundle: nil)
        // 单元格
        self.tableView .register(nib, forCellReuseIdentifier: kHLAuthEmergencyMobileListCell)
        self.searchTableView.register(nib, forCellReuseIdentifier: kHLAuthEmergencyMobileListCell)
        
        self.fakeSearchBarBtn.layer.cornerRadius = 15.0
        self.fakeSearchBarBtn.layer.masksToBounds = true
        self.title = "请选择联系人"
    }
    
    // 配置表格数据
    // 排序
    func requestData() -> Void{
        self.fetchContactData()
    }
    
    
    func fetchContactData() -> Void {
        let _ = HLAddressBookManager.shared.requestAddressBookAccess { (granted) in
            if granted{
                self.originalAddressData = NSMutableArray(array: HLAddressBookManager.shared.readRecords())
                self.doAfterOriginalDataUpdated(data: self.originalAddressData)
            }
            else{
                print("用户拒绝使用通讯录")
            }
        }
    }
    
    //数据处理：排序、传给后端，更新UI
    func doAfterOriginalDataUpdated(data:NSMutableArray){
        
        // 获取联系人信息
        //得出27个索引
        let collation = UILocalizedIndexedCollation.current()
        let sectionTitles = collation.sectionTitles.count
        //self.sectionTitleArr存放section数组
        self.sectionTitleArr = NSMutableArray(array: collation.sectionTitles)
        //初始化27个空数组 self.dataArrays存放numberOfRowsInSection
        var i = 0
        while i<sectionTitles {
            let arr = NSMutableArray()
            self.dataArrays.add(arr)
            i += 1
        }
        for tmpObj in self.originalAddressData {
            let obj = tmpObj as! HLAddressBookModel
            if obj.name != "" {
                let sectionNum = collation.section(for: obj, collationStringSelector: #selector(getter: obj.name))
                let array:NSMutableArray = self.dataArrays[sectionNum] as! NSMutableArray
                array.add(obj)
            }
        }
        
        //对每个section中的数组按name排序
        for i in 0..<self.dataArrays.count {
            let arr:NSMutableArray = self.dataArrays[i] as! NSMutableArray
            let sortArr = collation.sortedArray(from: arr as [AnyObject], collationStringSelector: #selector(getter: HLAddressBookModel.name))
            arr.removeAllObjects()
            arr.addObjects(from: sortArr)
        }
        
        
        //去掉无数据的数组
        let tmpArrA = NSMutableArray()
        let tmpArrB = NSMutableArray()
        
        for i in 0..<self.dataArrays.count {
            let arr = self.dataArrays[i]
            if (arr as AnyObject).count == 0 {
                tmpArrA.add(self.sectionTitleArr[i])
                tmpArrB.add(self.dataArrays[i])
            }
        }
        
        for i in 0..<tmpArrA.count {
            self.sectionTitleArr.remove(tmpArrA[i])
            self.dataArrays.remove(tmpArrB[i])
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
   
    // 过滤搜索结果
    func filterContentForSearchText(searchText: String) {
        self.filteredDataArrays = NSMutableArray(array: self.originalAddressData)
        // 过滤
        /*
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", "Ansel"];
         NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
         */
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        filteredDataArrays.filter(using: predicate)
        /*
        filteredDataArrays = filteredCities.filter({
            let tobeEvaluated = $0.cityName
            let tobeEvaluated2 = $0.cityFirstLetter
            let predicate = NSPredicate(format: "SELF CONTAINS[cd] %@", searchText)
            return (predicate.evaluate(with: tobeEvaluated) || predicate.evaluate(with: tobeEvaluated2))
        })
         */
        self.searchTableView .reloadData()
    }
    
    
     
    //MARK: - delegate
    
    
    
    //MARK: - setter & getter
}

extension HLAuthEmergencyMobileListVC:UITableViewDelegate,UITableViewDataSource{
    //MARK: UITableViewDelegate && UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (tableView == self.searchTableView){
            return 1
        }
        else{
            return self.dataArrays.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.searchTableView) {
            return self.filteredDataArrays.count
        }
        else{
            let tmpArr = (dataArrays[section]) as! NSArray
            return tmpArr.count
        }
        
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("")
        // searchController is active,only one section
        if (self.isCurrentOnSearchState()){
            let mobile = (self.originalAddressData[indexPath.row] as! HLAddressBookModel).mobile
            guard let aClosure = self.selectCompleteClosure else { return  }
            aClosure(mobile)
            return
        }
        
        let model = (self.dataArrays[indexPath.section] as! NSArray)[indexPath.row] as! HLAddressBookModel
        guard let aClosure = self.selectCompleteClosure else { return  }
        // 回调
        aClosure(model.mobile)
        
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kHLAuthEmergencyMobileListCell) as! HLAuthEmergencyMobileListCell
        // 正在搜索
        if (tableView == self.searchTableView){
            
            let model = self.filteredDataArrays[indexPath.row] as! HLAddressBookModel
            cell.configModel(model: model, onTapClosure: { (theCell) in
               self.doAfterSearchCellSelected(cell: theCell)
            })
            
            return cell
            
        }
        else{
            let model = (self.dataArrays[indexPath.section] as! NSArray)[indexPath.row] as! HLAddressBookModel
            cell.configModel(model: model, onTapClosure: { (theCell) in
                self.doAfterNormalCellSelected(cell: theCell)
            })
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == self.searchTableView){
            return 0.0
        }
        else{
            return 28.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (tableView == self.searchTableView){
            return nil
        }
        let rsView = UIView()
        rsView.backgroundColor = UIColor.white
        let spitView = UIView(frame: CGRect(x: 12, y: 27.5, width: kScreenWidth, height: 0.5))
        spitView.backgroundColor = UIColor.lightGray
        rsView .addSubview(spitView)
        
        let sectionLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 50, height: 28))
        sectionLabel.textColor = UIColor.gray
        
        let sectionText:String =  self.sectionTitleArr[section] as! String
        
        sectionLabel.text = sectionText
        sectionLabel.font = UIFont.systemFont(ofSize: 12)
        rsView .addSubview(sectionLabel)
        return rsView
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if(tableView == self.searchTableView){
            return [String]()
        }
        return (self.sectionTitleArr as! [String])
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}
