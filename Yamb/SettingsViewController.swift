//
//  SettingsViewController.swift
//  Yamb
//
//  Created by Martin Peshevski on 15.3.21.
//

import UIKit

class SettingsSelectionView: UIView {
    lazy var container: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fill
        s.addArrangedSubview(titleLabel)
        s.addArrangedSubview(selector)
        
        return s
    }()
    
    lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        return l
    }()
    
    var selector: UISegmentedControl
    
    init(title: String, values: [String]) {
        selector = UISegmentedControl(frame: .zero)
        for (i, value) in values.enumerated() {
            selector.setTitle(value, forSegmentAt: i)
        }
        super.init(frame: .zero)
        
        container.snp.makeConstraints { make in make.edges.equalToSuperview() }
        snp.makeConstraints { make in make.height.equalTo(50) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsViewController: UIViewController {
    @IBOutlet var container: UIStackView!
    
    let rollType = SettingsSelectionView(title: "Roll type:", values: ["Input", "Roll"])
    let columnNumber = SettingsSelectionView(title: "Columns:", values: ["4", "5", "6", "7", "8"])
    let stars = SettingsSelectionView(title: "Stars:", values: ["Enabled", "Disabled"])
    let superYamb = SettingsSelectionView(title: "Super Yamb:", values: ["Enabled", "Disabled"])
    let superStraight = SettingsSelectionView(title: "Super Straight:", values: ["Enabled", "Disabled"])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.addArrangedSubview(<#T##view: UIView##UIView#>)
    }
}
