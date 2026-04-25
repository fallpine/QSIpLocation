# QSIpLocation

QSIpLocation 是一个用于获取当前公网 IP 地址及 IP 归属地信息的 Swift 工具库。

库内会先获取当前设备出口公网 IP，再通过 IP 查询接口返回国家、地区、城市、经纬度、运营商等信息，并使用 `UserDefaults` 做 24 小时缓存。

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

调用 `IpLocation.getIpLocation` 获取当前 IP 地址信息：

```swift
IpLocation.getIpLocation { model in
    guard let model = model else {
        print("获取 IP 地址信息失败")
        return
    }

    print("IP: \(model.query ?? "")")
    print("国家: \(model.country ?? "")")
    print("省份/地区: \(model.regionName ?? "")")
    print("城市: \(model.city ?? "")")
    print("运营商: \(model.isp ?? "")")
    print("经纬度: \(model.lat ?? 0), \(model.lon ?? 0)")
}
```

回调会在主线程返回，可以直接在回调中更新 UI。

## 返回字段

`IpLocationModel` 支持以下字段：

| 字段 | 说明 |
| --- | --- |
| `query` | IP 地址 |
| `country` | 国家 |
| `countryCode` | 国家代码 |
| `region` | 地区代码 |
| `regionName` | 地区名称 |
| `city` | 城市 |
| `zip` | 邮政编码 |
| `lat` | 纬度 |
| `lon` | 经度 |
| `timezone` | 时区 |
| `isp` | 网络服务商 |
| `org` | 组织信息 |

## 注意事项

- 查询结果会缓存 24 小时，缓存期间重复调用会直接返回本地缓存。
- IP 归属地查询使用 `http://ip-api.com`，如果你的 App 开启了 ATS 限制，需要在 `Info.plist` 中为该域名配置网络访问例外。

## License

QSIpLocation is available under the MIT license. See the LICENSE file for more info.
