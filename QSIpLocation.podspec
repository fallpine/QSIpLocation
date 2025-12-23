Pod::Spec.new do |spec|
  spec.name         = "QSIpLocation"
  spec.version      = "1.0.1"
  spec.summary      = "ip地址"
  spec.description  = "获取ip地址工具类"
  spec.homepage     = "https://github.com/fallpine/QSIpLocation"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "QiuSongChen" => "791589545@qq.com" }
  spec.ios.deployment_target     = "15.0"
  spec.watchos.deployment_target = "8.0"
  spec.source       = { :git => "https://github.com/fallpine/QSIpLocation.git", :tag => "#{spec.version}" }
  spec.swift_version = '5'
  spec.source_files  = "QSIpLocation/QSIpLocation/Tool/*.{swift}"
  spec.dependency "QSNetRequest"
  spec.dependency "QSModelConvert"
end
