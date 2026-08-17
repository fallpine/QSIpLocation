//
//  IpLocation.swift
//  QSIpLocation
//
//  Created by MacM2 on 12/23/25.
//

import Foundation

public class QSIpLocation {

    // MARK: - Func
    public static func getIpLocation(completion: @escaping (QSIpLocationModel?) -> Void) {

        let now = Date().timeIntervalSince1970

        // 1. 检查缓存是否过期
        let loadTime = UserDefaults.standard.double(forKey: locationTimeKey)
        if now - loadTime > cacheDuration {
            UserDefaults.standard.removeObject(forKey: locationKey)
        }

        // 2. 读取缓存
        if let jsonStr = UserDefaults.standard.string(forKey: locationKey),
           let data = jsonStr.data(using: .utf8),
           let model = try? JSONDecoder().decode(QSIpLocationModel.self, from: data) {
            completion(model)
            return
        }

        fetchLocation(from: apiUrls, index: 0, completion: completion)
    }

    private static func fetchLocation(from apiUrls: [String], index: Int, completion: @escaping (QSIpLocationModel?) -> Void) {
        guard index < apiUrls.count else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        guard let url = URL(string: apiUrls[index]) else {
            fetchLocation(from: apiUrls, index: index + 1, completion: completion)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = makeLocationResult(from: json) else {
                fetchLocation(from: apiUrls, index: index + 1, completion: completion)
                return
            }

            if let str = String(data: result.jsonData, encoding: .utf8) {
                UserDefaults.standard.set(str, forKey: locationKey)
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: locationTimeKey)
            }

            DispatchQueue.main.async {
                completion(result.model)
            }
        }.resume()
    }

    private static func makeLocationResult(from json: [String: Any]) -> (model: QSIpLocationModel, jsonData: Data)? {
        var normalizedJson: [String: Any] = [:]

        setStringValue(in: &normalizedJson, key: "ip", values: json, sourceKeys: ["query", "ip", "ipAddress", "clientIp"])
        setStringValue(in: &normalizedJson, key: "countryCode", values: json, sourceKeys: ["countryCode", "country_code", "countryCodeAlpha2", "country"])
        setStringValue(in: &normalizedJson, key: "countryName", values: json, sourceKeys: ["country_name", "countryName", "country"])
        setStringValue(in: &normalizedJson, key: "regionCode", values: json, sourceKeys: ["region_code", "regionCode", "region"])
        setStringValue(in: &normalizedJson, key: "regionName", values: json, sourceKeys: ["regionName", "region_name", "region", "subdivision_1_name"])
        setStringValue(in: &normalizedJson, key: "cityName", values: json, sourceKeys: ["city", "cityName"])
        setStringValue(in: &normalizedJson, key: "cityCode", values: json, sourceKeys: ["cityCode", "city_code"])
        setStringValue(in: &normalizedJson, key: "timezone", values: json, sourceKeys: ["timezone", "timeZone", "time_zone"])
        setDoubleValue(in: &normalizedJson, key: "lat", values: json, sourceKeys: ["lat", "latitude"])
        setDoubleValue(in: &normalizedJson, key: "lon", values: json, sourceKeys: ["lon", "longitude"])

        if let loc = stringValue(from: json, sourceKeys: ["loc"]) {
            let coordinates = loc.split(separator: ",").map { String($0) }
            if coordinates.count == 2 {
                normalizedJson["lat"] = doubleValue(from: coordinates[0])
                normalizedJson["lon"] = doubleValue(from: coordinates[1])
            }
        }

        guard !normalizedJson.isEmpty,
              let jsonData = try? JSONSerialization.data(withJSONObject: normalizedJson),
              let model = try? JSONDecoder().decode(QSIpLocationModel.self, from: jsonData),
              let ip = model.ip,
              isValidIp(ip),
              hasLocationInfo(model) else {
            return nil
        }

        return (model, jsonData)
    }

    private static func setStringValue(in normalizedJson: inout [String: Any], key: String, values: [String: Any], sourceKeys: [String]) {
        guard let value = stringValue(from: values, sourceKeys: sourceKeys) else {
            return
        }

        normalizedJson[key] = value
    }

    private static func setDoubleValue(in normalizedJson: inout [String: Any], key: String, values: [String: Any], sourceKeys: [String]) {
        guard let value = doubleValue(from: values, sourceKeys: sourceKeys) else {
            return
        }

        normalizedJson[key] = value
    }

    private static func stringValue(from values: [String: Any], sourceKeys: [String]) -> String? {
        for sourceKey in sourceKeys {
            if let value = values[sourceKey] as? String {
                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedValue.isEmpty {
                    return trimmedValue
                }
            }

            if let value = values[sourceKey] as? NSNumber {
                return value.stringValue
            }
        }

        return nil
    }

    private static func doubleValue(from values: [String: Any], sourceKeys: [String]) -> Double? {
        for sourceKey in sourceKeys {
            if let value = doubleValue(from: values[sourceKey]) {
                return value
            }
        }

        return nil
    }

    private static func doubleValue(from value: Any?) -> Double? {
        if let value = value as? Double {
            return value
        }

        if let value = value as? NSNumber {
            return value.doubleValue
        }

        if let value = value as? String {
            return Double(value.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return nil
    }

    private static func hasLocationInfo(_ model: QSIpLocationModel) -> Bool {
        return model.ip != nil ||
            model.countryCode != nil ||
            model.countryName != nil ||
            model.regionCode != nil ||
            model.regionName != nil ||
            model.cityName != nil ||
            model.cityCode != nil ||
            model.lat != nil ||
            model.lon != nil
    }

    private static func isValidIp(_ ip: String) -> Bool {
        return isValidIpv4(ip) || isValidIpv6(ip)
    }

    private static func isValidIpv4(_ ip: String) -> Bool {
        var address = in_addr()
        return ip.withCString { inet_pton(AF_INET, $0, &address) == 1 }
    }

    private static func isValidIpv6(_ ip: String) -> Bool {
        var address = in6_addr()
        return ip.withCString { inet_pton(AF_INET6, $0, &address) == 1 }
    }

    // MARK: - Property
    private static let apiUrls = [
        "http://ip-api.com/json/",
        "https://free.freeipapi.com/api/json/",
        "https://ipinfo.io/json",
        "https://ipv4-check-perf.radar.cloudflare.com/api/info",
        "https://ipapi.co/json/"
    ]

    private static let locationKey = "kQSIpLocationModelKey"
    private static let locationTimeKey = "kQSIpLocationModelLoadTimeKey"

    private static let cacheDuration: TimeInterval = 60 * 60 * 24 // 24小时
}
