//
//	HLAddressBookModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 


class HLAddressBookModel : NSObject, NSCoding{

    var isSelected : Bool!
	var mobile : String!
	@objc var name : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    init(fromName name:String,mobile:String,isSelected:Bool = false){
		self.name = name
        self.mobile = mobile
        self.isSelected = isSelected
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if isSelected != nil{
			dictionary["isSelected"] = isSelected
		}
		if mobile != nil{
			dictionary["mobile"] = mobile
		}
		if name != nil{
			dictionary["name"] = name
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         isSelected = aDecoder.decodeObject(forKey: "isSelected") as? Bool
         mobile = aDecoder.decodeObject(forKey: "mobile") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if isSelected != nil{
			aCoder.encode(isSelected, forKey: "isSelected")
		}
		if mobile != nil{
			aCoder.encode(mobile, forKey: "mobile")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}

	}

}
