//
//  CellEnums.swift
//  Yamb
//
//  Created by Martin Peshevski on 5.1.21.
//

import Foundation

let thrillingModifier = 20
let straightModifier = 30
let fullModifier = 40
let pokerModifier = 50
let yambModifier = 60

enum Column {
    case down
    case up
    case free
    case midOut
    case outMid
    case announce
    case disannounce
    case hand
}

enum Row {
    case ones
    case twos
    case threes
    case fours
    case fives
    case sixes
    case min
    case max
    case thrilling
    case straight
    case full
    case poker
    case yamb
    
    func calculate(diceRolls: [DiceRoll]) -> Int {
        switch self {
        case .ones: return diceRolls.sum(.one)
        case .twos: return diceRolls.sum(.two)
        case .threes: return diceRolls.sum(.three)
        case .fours: return diceRolls.sum(.four)
        case .fives: return diceRolls.sum(.five)
        case .sixes: return diceRolls.sum(.six)
        case .min: return diceRolls.max
        case .max: return diceRolls.min
        case .thrilling: return diceRolls.thriller
        case .straight: return diceRolls.straight
        case .full: return diceRolls.full
        case .poker: return diceRolls.poker
        case .yamb: return diceRolls.yamb
        }
    }
    
    var modifier: Int {
        switch self {
        case .ones, .twos, .threes, .fours, .fives, .sixes, .min, .max: return 0
        case .thrilling: return thrillingModifier
        case .straight: return straightModifier
        case .full: return fullModifier
        case .poker: return pokerModifier
        case .yamb: return yambModifier
        }
    }
    
    static func fromIndexPath(_ indexPath: IndexPath, numberOfColumns: Int) -> Row? {
        if indexPath.section == 0 {
            if indexPath.row / numberOfColumns == 0 { return .ones}
            if indexPath.row / numberOfColumns == 1 { return .twos}
            if indexPath.row / numberOfColumns == 2 { return .threes}
            if indexPath.row / numberOfColumns == 3 { return .fours}
            if indexPath.row / numberOfColumns == 4 { return .fives}
            if indexPath.row / numberOfColumns == 5 { return .sixes}
        } else if indexPath.section == 1 {
            if indexPath.row / numberOfColumns == 0 { return .max}
            if indexPath.row / numberOfColumns == 1 { return .min}
        } else if indexPath.section == 2 {
            if indexPath.row / numberOfColumns == 0 { return .thrilling}
            if indexPath.row / numberOfColumns == 1 { return .straight}
            if indexPath.row / numberOfColumns == 2 { return .full}
            if indexPath.row / numberOfColumns == 3 { return .poker}
            if indexPath.row / numberOfColumns == 4 { return .yamb}
        }
        
        return nil
    }
}

enum DiceRoll: Int {
    case one = 1
    case two
    case three
    case four
    case five
    case six
}

extension Collection where Element == DiceRoll {
    func sum(_ diceRoll: DiceRoll) -> Int {
        if !self.contains(diceRoll) { return 0 }
        return self.filter{ $0 == diceRoll }.prefix(5).map{ $0.rawValue }.reduce(0, +)
    }
    
    var max: Int {
        return self.sorted { $0.rawValue < $1.rawValue }.prefix(5).map{ $0.rawValue }.reduce(0, +)
    }
    
    var min: Int {
        return self.sorted { $0.rawValue > $1.rawValue }.prefix(5).map{ $0.rawValue }.reduce(0, +)
    }
    
    var thriller: Int {
        let histogram: [DiceRoll: Int] = self.histogram
        
        let keys = histogram.keys.sorted { $0.rawValue < $1.rawValue }
        for key in keys {
            if histogram[key] ?? 0 >= 3 { return (3 * key.rawValue) + thrillingModifier }
        }
        
        return 0
    }
    
    var straight: Int {
        let sorted = Array(Set(self)).sorted { $0.rawValue < $1.rawValue }
        if sorted.elementsEqual([.one, .two, .three, .four, .five]) ||
            sorted.elementsEqual([.one, .two, .three, .four, .five, .six]) ||
            sorted.elementsEqual([.two, .three, .four, .five, .six])
        {
            return sorted.map{ $0.rawValue }.reduce(0, +) + straightModifier
        }
        
        return 0
    }
    
    var full: Int {
        let histogram: [DiceRoll: Int] = self.histogram
        let keys = histogram.keys.sorted { $0.rawValue > $1.rawValue }
        
        var threeOf = 0
        var twoOf = 0
        var threeOfKey: DiceRoll? = nil
        
        for key in keys {
            if histogram[key] ?? 0 >= 5 {
                return (5 * key.rawValue) + fullModifier
            }
            
            if histogram[key] ?? 0 >= 3 {
                threeOf = 3 * key.rawValue
                threeOfKey = key
            }
        }
        
        for key in keys where key != threeOfKey {
            if histogram[key] ?? 0 >= 2 {
                twoOf = 2 * key.rawValue
            }
        }
        
        if threeOf > 0 && twoOf > 0 { return threeOf + twoOf + fullModifier}
        
        return 0
    }
    
    var poker: Int {
        let histogram: [DiceRoll: Int] = self.histogram
        
        let keys = histogram.keys.sorted { $0.rawValue > $1.rawValue }
        for key in keys {
            if histogram[key] ?? 0 >= 4 { return (4 * key.rawValue) + pokerModifier }
        }
        
        return 0
    }
    
    var yamb: Int {
        let histogram: [DiceRoll: Int] = self.histogram
        
        let keys = histogram.keys.sorted { $0.rawValue > $1.rawValue }
        for key in keys {
            if histogram[key] ?? 0 >= 5 { return (5 * key.rawValue) + yambModifier }
        }
        
        return 0
    }
}

extension Sequence where Element: Hashable {
    var histogram: [Element: Int] {
        return self.reduce(into: [:]) { counts, elem in counts[elem, default: 0] += 1 }
    }
}
