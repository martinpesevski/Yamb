//
//  ViewController.swift
//  Yamb
//
//  Created by Martin Peshevski on 31.12.20.
//

import UIKit

class YambViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DiceSelectionDelegate {

    @IBOutlet var yambCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yambCollectionView.register(YambCell.self, forCellWithReuseIdentifier: "numberCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/5 - 3, height: 45)
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        yambCollectionView.collectionViewLayout = flowLayout;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 30
        case 1: return 10
        case 2: return 25
        default: return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "numberCell", for: indexPath) as? YambCell ?? YambCell()
        cell.row = Row.fromIndexPath(indexPath, numberOfColumns: 5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? YambCell else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let diceSelection = storyboard.instantiateViewController(withIdentifier: "diceSelection") as? DiceSelectionViewController else { return }
        diceSelection.cell = cell
        diceSelection.delegate = self
        self.present(diceSelection, animated: true)
        
//        performSegue(withIdentifier: "showDiceSelect", sender: self)
//        cell.setupDiceRolls([DiceRoll(rawValue: Int.random(in: 1...6))!,
//                             DiceRoll(rawValue: Int.random(in: 1...6))!,
//                             DiceRoll(rawValue: Int.random(in: 1...6))!,
//                             DiceRoll(rawValue: Int.random(in: 1...6))!,
//                             DiceRoll(rawValue: Int.random(in: 1...6))!,
//                             DiceRoll(rawValue: Int.random(in: 1...6))!])
    }
    
    func didSelect(_ diceRolls: [DiceRoll], cell: YambCell) {
        cell.setupDiceRolls(diceRolls)
    }
}
