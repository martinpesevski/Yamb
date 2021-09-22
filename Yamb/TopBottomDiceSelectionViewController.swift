//
//  TopBottomDiceSelectionViewController.swift
//  Yamb
//
//  Created by Martin Peshevski on 15.1.21.
//

import UIKit

class TopBottomDiceSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var addStarSwitch: UISwitch!
    
    var field: Field?
    weak var delegate: DiceSelectionDelegate?
    var shouldShowClear = false
    
    override func viewDidLoad() {
        
        collectionView.register(TopBottomCollectionCell.self, forCellWithReuseIdentifier: "topBottomCell")
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        titleLabel.text = field?.row?.longTitle
        clearButton.isHidden = !shouldShowClear
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topBottomCell", for: indexPath) as? TopBottomCollectionCell ?? TopBottomCollectionCell()
        if let row = field?.row, let data = row.section.nameAndRolls(row: row)[indexPath.section]?[indexPath.row] {
            cell.setup(data: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let row = field?.row, let data = row.section.nameAndRolls(row: row)[indexPath.section]?[indexPath.row] {
            delegate?.didSelect(data.1, indexPath: field?.indexPath, hasStar: addStarSwitch.isOn)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let row = field?.row else { return 0 }
        return row.section.nameAndRolls(row: row).keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let row = field?.row else { return 0 }
        switch row.section {
        case .top: return 6
        case .bottom: return row.section.nameAndRolls(row: row)[section]?.count ?? 0
        case .middle: return 0
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAddStarValueChanged(_ sender: UISwitch) {
        field?.hasStar = sender.isSelected
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.didClear(indexPath: field?.indexPath)
        dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
}

class TopBottomCollectionCell: UICollectionViewCell {
    lazy var titleLabel = UILabel()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 3
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(UIView())
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        layer.borderColor = UIColor.label.cgColor
        layer.cornerRadius = 5
        layer.borderWidth = 1
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func setup(data: (title: String, diceRolls: [DiceRoll])) {
        titleLabel.text = data.title
        for view in stackView.arrangedSubviews where view is UIImageView {
            view.removeFromSuperview()
        }
        for diceRoll in data.diceRolls {
            let imageView = UIImageView(image: diceRoll.image)
            imageView.snp.makeConstraints { make in make.width.height.equalTo(30) }
            stackView.addArrangedSubview(imageView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
