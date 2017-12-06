//
//  HLAuthEmergencyMobileListCell.swift
//  HLCreditV2
//
//  Created by HuanLeiMac on 2017/12/4.
//  Copyright © 2017年 VisionMicrocreditCo. All rights reserved.
//

import UIKit


class HLAuthEmergencyMobileListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var selectStateImg: UIImageView!
    
    private var normalOnTapClosure :((_ aCell:HLAuthEmergencyMobileListCell)->Void)? = nil
    var model:HLAddressBookModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func cellPressed(_ sender: UIButton) {
        self.normalOnTapGS()
    }
    
    
    func configModel(model:HLAddressBookModel,onTapClosure:@escaping ((_ aCell:HLAuthEmergencyMobileListCell)->Void)) -> Void {
        self.model = model
        self.normalOnTapClosure = onTapClosure
        
        let isSelected = self.model?.isSelected ?? false
        let selectedImgName = isSelected ? "emergencyContactPage_selected" : "emergencyContactPage_deselected"
        self.selectStateImg.image = UIImage(named: selectedImgName)
        self.nameLabel.text = model.name
        self.telLabel.text = model.mobile
        
    }
    
    /// 更新model 的selected 对象
    ///
    /// - Parameter selected:
    func updateModelSelected(selected:Bool) -> Void {
        self.model?.isSelected = selected
    }
    
    
    private func normalOnTapGS() -> Void {
        
        guard let aClosure = self.normalOnTapClosure else { return }
        aClosure(self)
    }
    
}
