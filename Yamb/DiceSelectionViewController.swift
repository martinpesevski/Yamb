//
//  DiceSelectionViewController.swift
//  Yamb
//
//  Created by Martin Peshevski on 6.1.21.
//

import UIKit

protocol DiceSelectionDelegate: class {
    func didSelect(_ diceRolls: [DiceRoll], cell: YambCell)
}

class DiceSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var selectedCollection: UICollectionView!
    
    var diceRolls: [DiceRoll] = []
    weak var delegate: DiceSelectionDelegate?
    var cell: YambCell?
    
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
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diceRolls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = selectedCollection.dequeueReusableCell(withReuseIdentifier: "selectionCell", for: indexPath) as? DiceCell ?? DiceCell(frame: .zero)
        cell.setup(diceRoll: diceRolls[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        diceRolls.remove(at: indexPath.row)
        selectedCollection.reloadData()
    }
    
    @IBAction func onSelect(_ sender: UIButton) {
        guard let diceRoll = DiceRoll(rawValue: sender.tag), diceRolls.count < 6 else { return }
        diceRolls.append(diceRoll)
        selectedCollection.reloadData()
    }
    
    @IBAction func onDone(_ sender: Any) {
        guard let cell = cell else { return }
        delegate?.didSelect(diceRolls, cell: cell)
        dismiss(animated: true, completion: nil)
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
