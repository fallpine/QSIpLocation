//
//  IpLocation.swift
//  QSIpLocation
//
//  Created by MacM2 on 12/23/25.
//

import Foundation
import QSNetRequest
import QSJsonParser

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
                    if let model = stringToModel(jsonStr, modelType: IpLocationModel.self) {
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
            
            if let model = jsonToModel(dict, modelType: IpLocationModel.self) {
                onCompletion(model)
            } else {
                onCompletion(nil)
            }
        } onError: { _, _ in
            onCompletion(nil)
        }
    }
    
    /// 将字典字符串转换为Model
    static func stringToModel<T: Decodable>(_ string: String, modelType: T.Type) -> T? {
        guard let json = JsonParser.jsonStringToDictionary(with: string) else {
            return nil
        }
        return jsonToModel(json, modelType: modelType)
    }
    
    /// 将字典转换为Model
    static func jsonToModel<T: Decodable>(_ json: Any, modelType: T.Type) -> T? {
        if !JSONSerialization.isValidJSONObject(json) {
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return decodedObject
        } catch {
            return nil
        }
    }
}
