//
//  DiceSelectionViewController.swift
//  Yamb
//
//  Created by Martin Peshevski on 6.1.21.
//

import UIKit

protocol DiceSelectionDelegate: AnyObject {
    func didSelect(_ diceRolls: [DiceRoll], indexPath: IndexPath?, hasStar: Bool)
    func didClear(indexPath: IndexPath?)
    func didDismiss()
}

class MinMaxDiceSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var selectedCollection: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var clearButton: UIButton!

    var diceRolls: [DiceRoll] = []
    weak var delegate: DiceSelectionDelegate?
    var field: Field?
    
    var shouldShowClear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedCollection.register(DiceCell.self, forCellWithReuseIdentifier: "selectionCell")
        selectedCollection.delegate = self
        selectedCollection.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 40)/3 - 10, height: (UIScreen.main.bounds.width - 40)/3 - 10)
        selectedCollection.collectionViewLayout = flowLayout;
        titleLabel.text = field?.row?.longTitle
        
        clearButton.isHidden = !shouldShowClear
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diceRolls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = selectedCollection.dequeueReusableCell(withReuseIdentifier: "selectionCell", for: indexPath) as? DiceCell ?? DiceCell(frame: .zero)
        cell.setup(diceRoll: diceRolls[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        diceRolls.remove(at: indexPath.item)
        selectedCollection.reloadData()
    }
    
    @IBAction func onSelect(_ sender: UIButton) {
        guard let diceRoll = DiceRoll(rawValue: sender.tag), diceRolls.count < 6 else { return }
        diceRolls.append(diceRoll)
        selectedCollection.reloadData()
    }
    
    @IBAction func onDone(_ sender: Any) {
        if field?.row?.fiveDiceRequired == true && diceRolls.count < 5 {
            let alert = UIAlertController(title: nil, message: "You must select at least five dice", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        delegate?.didSelect(diceRolls, indexPath: field?.indexPath, hasStar: false)
        dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
    
    @IBAction func onClear(_ sender: Any) {
        delegate?.didClear(indexPath: field?.indexPath)
        dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
}

class DiceCell: UICollectionViewCell {
    lazy var image = UIImageView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        image.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(diceRoll: DiceRoll) {
        image.image = diceRoll.image
    }
}
