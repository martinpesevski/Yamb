//
//  CellEnums.swift
//  Yamb
//
//  Created by Martin Peshevski on 5.1.21.
//

import UIKit

let thrillingModifier = 20
let straightModifier = 30
let largeStraightFlat = 100
let yambOnes = 101
let fullModifier = 40
let pokerModifier = 50
let yambModifier = 60

enum Column {
    case rowNames
    case down
    case up
    case free
    case midOut
    case outMid
    case announce
    case disannounce
    case hand
    
    var headerTitle: String {
        switch self {
        case .rowNames: return ""
        case .down: return "\u{2193}"
        case .up: return "\u{2191}"
        case .free: return "F"
        case .midOut: return "\u{21F3}"
        case .outMid: return "\u{29D6}"
        case .announce: return "A"
        case .disannounce: return "DA"
        case .hand: return "H"
        }
    }
    
    var description: String {
        switch self {
        case .rowNames: return ""
        case .down: return "Populate this column in order from Ones to Yamb"
        case .up: return "Populate this column in reverse order from Yamb to One"
        case .free: return "Populate this column in any order"
        case .midOut: return "Populate this column starting from Max to One, and starting from Min to Yamb"
        case .outMid: return "Populate this column starting from One to Max, and starting from Yamb to Min"
        case .announce: return "Populate this column in any order, but you need to announce the field that you will be populating after the first dice throw"
        case .disannounce: return "Populate this column after the previous opponent filled the announce field of the same row"
        case .hand: return "Populate this column in any order, after throwing six dice at once"
        }
    }
}

enum Row: Int {
    case ones
    case twos
    case threes
    case fours
    case fives
    case sixes
    case max
    case min
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
        case .ones, .twos, .threes, .fours, .fives, .sixes, .max, .min: return 0
        case .thrilling: return thrillingModifier
        case .straight: return straightModifier
        case .full: return fullModifier
        case .poker: return pokerModifier
        case .yamb: return yambModifier
        }
    }
    
    var title: String {
        switch self {
        case .ones: return "1"
        case .twos: return "2"
        case .threes: return "3"
        case .fours: return "4"
        case .fives: return "5"
        case .sixes: return "6"
        case .min: return "Min"
        case .max: return "Max"
        case .thrilling: return "T"
        case .straight: return "S"
        case .full: return "F"
        case .poker: return "P"
        case .yamb: return "Y"
        }
    }
    
    var longTitle: String {
        switch self {
        case .ones: return "Ones"
        case .twos: return "Twos"
        case .threes: return "Threes"
        case .fours: return "Fours"
        case .fives: return "Fives"
        case .sixes: return "Sixes"
        case .min: return "Minimum. You must select at least 5 dice"
        case .max: return "Maximum. You must select at least 5 dice"
        case .thrilling: return "Thrilling"
        case .straight: return "Straight"
        case .full: return "Full house"
        case .poker: return "Poker"
        case .yamb: return "Yamb"
        }
    }
    
    var fiveDiceRequired: Bool {
        switch self {
        case .min, .max: return true
        default: return false
        }
    }
    
    var associatedDiceRoll: DiceRoll? {
        switch self {
        case .ones: return .one
        case .twos: return .two
        case .threes: return .three
        case .fours: return .four
        case .fives: return .five
        case .sixes: return .six
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .ones: return "The sum of your \"One\" dice rolls"
        case .twos: return "The sum of your \"Two\" dice rolls"
        case .threes: return "The sum of your \"Three\" dice rolls"
        case .fours: return "The sum of your \"Four\" dice rolls"
        case .fives: return "The sum of your \"Five\" dice rolls"
        case .sixes: return "The sum of your \"Six\" dice rolls"
        case .max: return "The highest total sum of 5 dice"
        case .min: return "The lowest total sum of 5 dice"
        case .thrilling: return "Three of a kind. A bonus of 20 is added to the sum"
        case .straight: return "the sum of 5 or 6 dice in a row. A bonus of 30 is added to the sum. If you get a straight from 1-6, the score is 100"
        case .full: return "Three of a kind, paired with two of a kind. A bonus of 40 is added to the sum. It is possible to put in 5 of a kind instead"
        case .poker: return "Four of a kind. A bonus of 50 is added to the sum."
        case .yamb: return "Five of a kind. A bonus of 60 is added to the sum. If you get 5 Ones, the score is 101 instead of 65"
        }
    }
    
    var section: Section {
        switch self {
        case .ones, .twos, .threes, .fours, .fives, .sixes: return .top
        case .min, .max: return .middle
        case .thrilling, .straight, .full, .poker, .yamb: return .bottom
        }
    }
    
    static func fromIndexPath(_ indexPath: IndexPath, numberOfColumns: Int) -> Row? {
        if indexPath.section == 0 {
            if indexPath.item / numberOfColumns == 1 { return .ones}
            if indexPath.item / numberOfColumns == 2 { return .twos}
            if indexPath.item / numberOfColumns == 3 { return .threes}
            if indexPath.item / numberOfColumns == 4 { return .fours}
            if indexPath.item / numberOfColumns == 5 { return .fives}
            if indexPath.item / numberOfColumns == 6 { return .sixes}
        } else if indexPath.section == 1 {
            if indexPath.item / numberOfColumns == 0 { return .max}
            if indexPath.item / numberOfColumns == 1 { return .min}
        } else if indexPath.section == 2 {
            if indexPath.item / numberOfColumns == 0 { return .thrilling}
            if indexPath.item / numberOfColumns == 1 { return .straight}
            if indexPath.item / numberOfColumns == 2 { return .full}
            if indexPath.item / numberOfColumns == 3 { return .poker}
            if indexPath.item / numberOfColumns == 4 { return .yamb}
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
    
    var image: UIImage {
        switch self {
        case .one: return UIImage(named: "dice1") ?? UIImage()
        case .two: return UIImage(named: "dice2") ?? UIImage()
        case .three: return UIImage(named: "dice3") ?? UIImage()
        case .four: return UIImage(named: "dice4") ?? UIImage()
        case .five: return UIImage(named: "dice5") ?? UIImage()
        case .six: return UIImage(named: "dice6") ?? UIImage()
        }
    }
}

enum Section {
    case top
    case middle
    case bottom
    
    func nameAndRolls(row: Row) -> [Int: [(String, [DiceRoll])]] {
        switch self {
        case .top:
            guard let diceroll = row.associatedDiceRoll else { return [:] }
            
            return [0: [
                        ("None", []),
                        ("One", [diceroll]),
                        ("Two", [diceroll, diceroll]),
                        ("Three", [diceroll, diceroll, diceroll]),
                        ("Four", [diceroll, diceroll, diceroll, diceroll]),
                        ("Five", [diceroll, diceroll, diceroll, diceroll, diceroll])]]
        case .middle: return [:]
        case .bottom:
            switch row {
            case .thrilling: return [0: [
                                        ("None", []),
                                        ("Ones", [.one, .one, .one]),
                                         ("Twos", [.two, .two, .two]),
                                         ("Threes", [.three, .three, .three]),
                                         ("Fours", [.four, .four, .four]),
                                         ("Fives", [.five, .five, .five]),
                                         ("Sixes", [.six, .six, .six])]]
            case .straight: return [0: [("Small", [.one, .two, .three, .four, .five]),
                                        ("Medium", [.two, .three, .four, .five, .six]),
                                        ("Large", [.one, .two, .three, .four, .five, .six])]]
            case .full: return [0: [
                                    ("None", []),
                                    ("Ones", [.one, .one, .one]),
                                    ("Twos", [.two, .two, .two]),
                                    ("Threes", [.three, .three, .three]),
                                    ("Fours", [.four, .four, .four]),
                                    ("Fives", [.five, .five, .five]),
                                    ("Sixes", [.six, .six, .six])],
                                1: [("Ones", [.one, .one]),
                                    ("Twos", [.two, .two]),
                                    ("Threes", [.three, .three]),
                                    ("Fours", [.four, .four]),
                                    ("Fives", [.five, .five]),
                                    ("Sixes", [.six, .six])]]
            case .poker: return [0: [
                                    ("None", []),
                                    ("Ones", [.one, .one, .one, .one]),
                                     ("Twos", [.two, .two, .two, .two]),
                                     ("Threes", [.three, .three, .three, .three]),
                                     ("Fours", [.four, .four, .four, .four]),
                                     ("Fives", [.five, .five, .five, .five]),
                                     ("Sixes", [.six, .six, .six, .six])]]
            case .yamb: return [0: [
                                    ("None", []),
                                    ("Ones", [.one, .one, .one, .one, .one]),
                                    ("Twos", [.two, .two, .two, .two, .two]),
                                    ("Threes", [.three, .three, .three, .three, .three]),
                                    ("Fours", [.four, .four, .four, .four, .four]),
                                    ("Fives", [.five, .five, .five, .five, .five]),
                                    ("Sixes", [.six, .six, .six, .six, .six])]]
            default: return [:]
            }
        }
    }
}

extension Collection where Element == Column {
    func columnFrom(indexPath: IndexPath) -> Column {
        let n = (indexPath.row % count)
        return n < 0 ? self[(count - 1) as! Self.Index] : self[n as! Self.Index]
    }
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
        
        let keys = histogram.keys.sorted { $0.rawValue > $1.rawValue }
        for key in keys {
            if histogram[key] ?? 0 >= 3 { return (3 * key.rawValue) + thrillingModifier }
        }
        
        return 0
    }
    
    var straight: Int {
        let sorted = Array(Set(self)).sorted { $0.rawValue < $1.rawValue }
        if sorted.elementsEqual([.one, .two, .three, .four, .five, .six]) { return largeStraightFlat }
        if sorted.elementsEqual([.one, .two, .three, .four, .five]) ||
            sorted.elementsEqual([.two, .three, .four, .five, .six])
        {
            return sorted.map{ $0.rawValue }.reduce(0, +) + straightModifier
        }
        
        return 0
    }
    
    var full: Int {
        let histogram: [DiceRoll: Int] = self.histogram
        let keys = histogram.keys.sorted { $0.rawValue < $1.rawValue }
        
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
            if histogram[key] ?? 0 >= 5 {
                if key == .one { return yambOnes }
                return (5 * key.rawValue) + yambModifier
            }
        }
        
        return 0
    }
    
    var hasStar: Bool {
        let histogram: [DiceRoll: Int] = self.histogram
        for key in histogram.keys {
            if histogram[key] ?? 0 >= 5 { return true }
        }
        
        return false
    }
}

extension Sequence where Element: Hashable {
    var histogram: [Element: Int] {
        return self.reduce(into: [:]) { counts, elem in counts[elem, default: 0] += 1 }
    }
}
