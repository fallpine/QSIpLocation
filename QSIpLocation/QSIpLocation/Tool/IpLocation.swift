//
//  IpLocation.swift
//  QSIpLocation
//
//  Created by MacM2 on 12/23/25.
//

import Foundation
import QSNetRequest
import QSJsonParser
import QSModelConvert

public class IpLocation {
    static let kIpLoacationLoadTimeKey = "kIpLoacationLoadTimeKey"
    static let kIpLoacationKey = "kIpLoacationKey"
    
    /// 获取ip所在地区
    public static func getIpLocation(onCompletion: @escaping ((IpLocationModel?) -> Void)) {
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let loadTime = UserDefaults.standard.value(forKey: kIpLoacationLoadTimeKey) as? String,
           let jsonStr = UserDefaults.standard.value(forKey: kIpLoacationKey) as? String {
            if let loadDate = dateFormatter.date(from: loadTime),
                let tomorrowDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: loadDate) {
                // 时间超过24小时，重新获取
                if Date() < tomorrowDate {
                    if let model = ModelConvert.stringToModel(jsonStr, modelType: IpLocationModel.self) {
                        onCompletion(model)
                        return
                    }
                }
            }
        }
        
        NetRequest.requestJson(urlString: "https://ipinfo.io/json",
                               methodType: .get,
                               paraDict: nil) { dict in
            if let jsonStr = JsonParser.objectToString(with: dict) {
                UserDefaults.standard.setValue(jsonStr, forKey: kIpLoacationKey)
                UserDefaults.standard.setValue(dateFormatter.string(from: Date()), forKey: kIpLoacationLoadTimeKey)
            }
            
            if let model = ModelConvert.jsonToModel(dict, modelType: IpLocationModel.self) {
                onCompletion(model)
            } else {
                onCompletion(nil)
            }
        } onError: { _, _ in
            onCompletion(nil)
        }
    }
}
