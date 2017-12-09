//
//  TextCleaner.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/9/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import Foundation

// we implement levenshtein to calculate edit distances between two strings.

struct Keyword{
    var PrimaryExpression: String
    var Alternatives: [String]
}

struct EditDistance{
    var word: String
    var distance: Int
}

let keywords: [Keyword]  = [
    Keyword(PrimaryExpression: "osc", Alternatives: ["osc", "oscillator", "oscillation", "osci"]),
    Keyword(PrimaryExpression: "output", Alternatives: ["out"]),
    Keyword(PrimaryExpression: "adsr", Alternatives: ["adsr", "dsr"]),
]

class TextCleaner{
    var text: String!
    init(text: String!){
        self.text = text
     
    }
    func ReturnLevens() -> String{
        var array:[Int] = []
        for i in keywords{
            let score = self.text.getLevenshtein(target: i.PrimaryExpression)
            array.append(score)
        }
        let lowest_score = array.min()
        let position = array.index(of: lowest_score!)
        print("Cloest keyword is: \(keywords[position!].PrimaryExpression)")
        return keywords[position!].PrimaryExpression
    }
    
    
    
}
