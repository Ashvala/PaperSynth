//
//  TextCleaner.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/9/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import Foundation

struct Keyword {
    var primaryExpression: String
    var alternatives: [String]
}

let keywords: [Keyword] = [
    Keyword(primaryExpression: "osc", alternatives: ["osc", "oscillator", "oscillation", "osci"]),
    Keyword(primaryExpression: "output", alternatives: ["out"]),
    Keyword(primaryExpression: "adsr", alternatives: ["adsr", "dsr"]),
    Keyword(primaryExpression: "del", alternatives: ["delay"]),
    Keyword(primaryExpression: "rev", alternatives: ["reverb"]),
    Keyword(primaryExpression: "mic", alternatives: ["microphone"]),
    Keyword(primaryExpression: "eq", alternatives: ["para-eq"])
]

class TextCleaner {
    var text: String!
    init(text: String!) {
        self.text = text
    }

    func returnLevens() -> String {
        var array: [Int] = []
        for i in keywords {
            let score = text.getLevenshtein(target: i.primaryExpression)
            array.append(score)
        }
        let lowest_score = array.min()
        let position = array.index(of: lowest_score!)
        print("Cloest keyword is: \(keywords[position!].primaryExpression)")
        return keywords[position!].primaryExpression
    }
}
