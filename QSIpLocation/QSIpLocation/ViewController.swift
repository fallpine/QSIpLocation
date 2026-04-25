//
//  ViewController.swift
//  QSIpLocation
//
//  Created by MacM2 on 12/23/25.
//

import UIKit

class ViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "IP 地址查询"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "点击按钮获取当前 IP 地址信息"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var fetchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("获取 IP 地址", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(fetchIpLocation), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(resultContainerView)
        resultContainerView.addSubview(resultLabel)
        view.addSubview(fetchButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            resultContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            resultContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),

            resultLabel.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 18),
            resultLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 18),
            resultLabel.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -18),
            resultLabel.bottomAnchor.constraint(lessThanOrEqualTo: resultContainerView.bottomAnchor, constant: -18),

            fetchButton.topAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: 28),
            fetchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            fetchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            fetchButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func fetchIpLocation() {
        setLoading(true)
        resultLabel.textColor = .secondaryLabel
        resultLabel.text = "正在获取 IP 地址信息..."

        IpLocation.getIpLocation { [weak self] model in
            guard let self = self else { return }
            self.setLoading(false)

            guard let model = model else {
                self.resultLabel.textColor = .systemRed
                self.resultLabel.text = "获取失败，请检查网络后重试。"
                return
            }

            self.resultLabel.textColor = .label
            self.resultLabel.text = self.makeResultText(with: model)
        }
    }

    private func setLoading(_ isLoading: Bool) {
        fetchButton.isEnabled = !isLoading
        fetchButton.alpha = isLoading ? 0.6 : 1
        fetchButton.setTitle(isLoading ? "获取中..." : "获取 IP 地址", for: .normal)
    }

    private func makeResultText(with model: IpLocationModel) -> String {
        let ip = model.query ?? "-"
        let country = model.country ?? "-"
        let countryCode = model.countryCode ?? "-"
        let region = model.regionName ?? "-"
        let city = model.city ?? "-"
        let isp = model.isp ?? "-"
        let latitude = model.lat.map { String($0) } ?? "-"
        let longitude = model.lon.map { String($0) } ?? "-"
        let timezone = model.timezone ?? "-"

        return """
        IP: \(ip)
        国家: \(country) (\(countryCode))
        地区: \(region)
        城市: \(city)
        ISP: \(isp)
        经纬度: \(latitude), \(longitude)
        时区: \(timezone)
        """
    }
}
