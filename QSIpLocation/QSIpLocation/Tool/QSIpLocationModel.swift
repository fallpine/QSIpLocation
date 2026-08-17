//
//  IpLocationModel.swift
//  QSIpLocation
//
//  Created by MacM2 on 12/23/25.
//

public class QSIpLocationModel: Decodable {
    public var countryName: String?
    public var countryCode: String?
    public var cityName: String?
    public var cityCode: String?
    public var regionName: String?
    public var regionCode: String?
    public var timezone: String?
    public var lon: Double?
    public var lat: Double?
    public var ip: String?
}
