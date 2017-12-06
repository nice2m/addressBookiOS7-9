//
//  HLAddressBookManager.swift
//  HLCreditV2
//
//  Created by HuanLeiMac on 2017/12/5.
//  Copyright © 2017年 VisionMicrocreditCo. All rights reserved.
//

import Foundation
import UIKit
import AddressBook
import Contacts



/// 用户通讯录权限状态
///
/// - notDetermined:未决定
/// - refused:拒绝
/// - authorized:已允许
enum HLAuthAddressBookAuthorizationStatus {
    case notDetermined
    case refused
    case authorized
}

class HLAddressBookManager {
    
    
    static let shared:HLAddressBookManager = HLAddressBookManager()
    
    
    //注意调用ABAddressBookCreateWithOptions进行ABAddressBookCreateWithOptions的初始化需要设置为一个lazy变量，否则在用户拒绝授权的情况下，程序将会崩溃。因为ABAddressBookCreateWithOptions(nil, nil)得到的值为nil。
    lazy var addressBook:ABAddressBook = {
        var emptyDictionary: CFDictionary?
        var errorRef: Unmanaged<CFError>?
        let ab:ABAddressBook = ABAddressBookCreateWithOptions(emptyDictionary, &errorRef).takeRetainedValue()
        return ab
    }()
    
    @available(iOS 9.0, *)
    lazy var contact:CNContactStore = CNContactStore()
    
    var originalAddressData = NSMutableArray() //用于存放通讯录里的原始有效数据
    
    
    
    
    //MARK: - interface
    //请求授权
    func requestAddressBookAccess(_ success:@escaping ((_ granted:Bool)->Void)) {
        if #available(iOS 9, *){
            self.contact.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                if !granted {
                    success(false)
                }else{
                    success(true)
                }
            })
        }else{
            ABAddressBookRequestAccessWithCompletion(self.addressBook) {(granted, error) in
                if !granted {
                    success(false)
                }else{
                    success(true)
                }
            }
        }
    }
    
    func readRecords() -> NSArray //原始有效数据
    {
        self.originalAddressData.removeAllObjects()
        if #available(iOS 9, *){
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPhoneNumbersKey] as [Any]
            
            try! self.contact.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor]), usingBlock: {[weak self] (contact, pointer) in
                var phone = ""
                
                for item in contact.phoneNumbers{
                    let phoneNum = item.value
                    let phoneString = phoneNum.stringValue
                    
                    let result = self?.removeUnuseChar(str: phoneString)
                    if self!.validateMobile(result!) {
                        phone = result!
                    }
                    if phone != "" {
                        let name:String = String(format: "%@%@", contact.givenName,contact.familyName)
                        var dict = [String:Any]()
                        /*
                         var isSelected : Bool!
                         var mobile : String!
                         var name : String!
                         var sortCode : String!
                         */
                        dict["mobile"] = phone
                        dict["name"] = name
                        
                        let obj:HLAddressBookModel = HLAddressBookModel.init(fromName: name, mobile: phone)
                        self?.originalAddressData.add(obj)
                        print("CNContact：\(name):\(phone)")
                    }
                }
            })
            return originalAddressData
        }else{
            
            let peoples = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as [ABRecord]
            
            for people: ABRecord in peoples {
                var firstName = ""
                var lastName = ""
                var phone = ""
                
                if let firstNameUnmanaged = ABRecordCopyValue(people, kABPersonLastNameProperty) {
                    firstName = firstNameUnmanaged.takeRetainedValue() as? String ?? ""
                }
                if let lastNameUnmanaged = ABRecordCopyValue(people, kABPersonFirstNameProperty) {
                    lastName = lastNameUnmanaged.takeRetainedValue() as? String ?? ""
                }
                
                let phoneNums: ABMultiValue = ABRecordCopyValue(people, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValue
                
                for index in 0..<ABMultiValueGetCount(phoneNums){
                    let label = ABMultiValueCopyValueAtIndex(phoneNums, index).takeRetainedValue() as! String
                    
                    let result = self.removeUnuseChar(str: label)
                    
                    if self.validateMobile(result) {
                        phone = result
                        break
                    }
                    
                }
                
                
                if phone != "" {
                    let name:String = String(format: "%@%@", lastName,firstName)
                    
                    var dict = [String:Any]()
                    /*
                     var isSelected : Bool!
                     var mobile : String!
                     var name : String!
                     var sortCode : String!
                     */
                    dict["mobile"] = phone
                    dict["name"] = name
                    let obj:HLAddressBookModel = HLAddressBookModel(fromName: name, mobile: phone)
                    self.originalAddressData.add(obj)
                    
                    print("ABAddressBook：\(name):\(phone)")
                }
                
            }
            return originalAddressData
        }
    }
    
    //MARK: - private
    //检测授权情况
    private func cheackAddressBookAuthorizationStatus() -> HLAuthAddressBookAuthorizationStatus {
        
        if #available(iOS 9, *) {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .denied,.restricted:
                return .refused
            case .authorized:
                return .authorized
            case .notDetermined:
                return .notDetermined
            }
        }else{
            switch ABAddressBookGetAuthorizationStatus() {
            case .denied,.restricted: //访问限制或者拒绝 弹出设置对话框
                return .refused
            case .authorized://已授权,加载数据
                return .authorized
            case .notDetermined://从未进行过授权操作、请求授权
                return .notDetermined
            }
        }
    }
    
    private func validateMobile(_ phoneNum:String)-> Bool {
        if phoneNum.characters.count != 11 || phoneNum.characters.count == 0 {
            return false
        }
        let mobile =  "^1[3|4|5|7|8][0-9]\\d{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        let isValid:Bool = regexMobile.evaluate(with: phoneNum)
        if !isValid {
            return false
        }
        return true
    }
    
    //有的手机系统读取到的手机号都有'-',所以去除'-'
    private func removeUnuseChar(str:String) -> String {
        var tmpStr = str
        for char in tmpStr.characters {
            if char == "-" {
                let range = tmpStr.range(of: "-")
                tmpStr.removeSubrange(range!)
            }
            
        }
        return tmpStr
    }
    
    
    
    /*
    func updateOroginalData(){
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
        for obj in self.originalAddressData {
            if obj.name != "" {
                let sectionNum = collation.section(for: obj, collationStringSelector: #selector(obj.nameMethod))
                let array:NSMutableArray = self.dataArrays[sectionNum] as! NSMutableArray
                array.add(obj)
            }
        }
        
        //对每个section中的数组按name排序
        for i in 0..<self.dataArrays.count {
            let arr:NSMutableArray = self.dataArrays[i] as! NSMutableArray
            let sortArr = collation.sortedArray(from: arr as [AnyObject], collationStringSelector: #selector(getter: xxClass.name))
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
        
        // tableView.reloadData()
    }
     */
}
