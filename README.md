# QSIpLocation

QSIpLocation 是一个用于获取当前网络 IP 地理位置信息的 Swift 工具库。

库内会直接通过多个地理信息接口获取当前 IP 位置信息，并使用 `UserDefaults` 做 24 小时缓存。接口会按顺序容灾请求，任意一个接口成功即返回结果；所有接口都失败时返回 `nil`。

## 环境要求

- iOS 15.0+
- watchOS 8.0+
- Swift 5

## 安装

使用 CocoaPods 安装：

```ruby
pod 'QSIpLocation'
```

然后执行：

```bash
pod install
```

## 使用方法

在需要使用的文件中引入模块：

```swift
import QSIpLocation
```

调用 `QSIpLocation.getIpLocation` 获取当前 IP 位置信息：

```swift
QSIpLocation.getIpLocation { model in
    guard let model = model else {
        print("获取 IP 位置信息失败")
        return
    }

    print("IP: \(model.ip ?? "")")
    print("国家: \(model.countryName ?? "")")
    print("国家代码: \(model.countryCode ?? "")")
    print("省份/地区: \(model.regionName ?? "")")
    print("省份/地区代码: \(model.regionCode ?? "")")
    print("城市: \(model.cityName ?? "")")
    print("城市代码: \(model.cityCode ?? "")")
    print("经纬度: \(model.lat ?? 0), \(model.lon ?? 0)")
    print("时区: \(model.timezone ?? "")")
}
```

回调会在主线程返回，可以直接在回调中更新 UI。

## 返回字段

`QSIpLocationModel` 支持以下字段：

| 字段 | 说明 |
| --- | --- |
| `ip` | IP 地址 |
| `countryName` | 国家名称 |
| `countryCode` | 国家代码 |
| `regionName` | 地区名称 |
| `regionCode` | 地区代码 |
| `cityName` | 城市名称 |
| `cityCode` | 城市代码 |
| `lat` | 纬度 |
| `lon` | 经度 |
| `timezone` | 时区 |

## 请求规则

当前会按以下 `apiUrls` 顺序请求：

```swift
private static let apiUrls = [
    "http://ip-api.com/json/",
    "https://free.freeipapi.com/api/json/",
    "https://ipinfo.io/json",
    "https://ipv4-check-perf.radar.cloudflare.com/api/info",
    "https://ipapi.co/json/"
]
```

一次接口请求满足以下条件时，会被认为成功：

- HTTP 状态码为 `2xx`。
- 响应内容是可解析的 JSON。
- JSON 能转换为 `QSIpLocationModel`。
- 返回的 `ip` 字段存在，并且是合法 IPv4 或 IPv6。
- 至少包含一个有效位置信息字段。

以下情况会认为当前接口失败，并继续请求下一个 URL：

- URL 无效。
- 网络请求失败或超时。
- HTTP 状态码不是 `2xx`。
- 响应数据为空或不是 JSON。
- 模型转换失败。
- `ip` 为空或格式不正确。

当所有 URL 都失败时，最终回调 `nil`。

## 注意事项

- 查询结果会缓存 24 小时，缓存期间重复调用会直接返回本地缓存。
- 当前接口列表包含 `http://ip-api.com/json/`。如果你的 App 开启了 ATS 限制，需要在 `Info.plist` 中为该域名配置网络访问例外，或移除该 HTTP 接口。
- 如果需要调整容灾顺序，修改 `QSIpLocation.swift` 中的 `apiUrls` 即可。

## License

QSIpLocation is available under the MIT license. See the LICENSE file for more info.
