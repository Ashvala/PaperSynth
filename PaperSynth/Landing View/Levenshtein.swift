//
//  Levenshtein.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/9/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import Foundation

// Credit to a Github gist for this. 

public func min3(a: Int, b: Int, c: Int) -> Int {
    
    return min( min(a, c), min(b, c))
    
}



public extension String {
    
    subscript(index: Int) -> Character {
        
        return self[index]
        
    }
    
    subscript(range: Range<Int>) -> String {
        
        let char0 = range.lowerBound
        
        let charN = range.upperBound
        
        return self[char0..<charN]
        
    }
    
}

public struct Array2D {
    
    var columns: Int
    var rows: Int
    var matrix: [Int]
    
    
    init(columns: Int, rows: Int) {
        
        self.columns = columns
        
        self.rows = rows
        

        matrix = Array(repeating:0, count:columns*rows)
        
    }
    
    subscript(column: Int, row: Int) -> Int {
        
        get {
            
            return matrix[columns * row + column]
            
        }
        
        set {
            
            matrix[columns * row + column] = newValue
            
        }
        
    }
    
    func columnCount() -> Int {
        
        return self.columns
        
    }
    
    func rowCount() -> Int {
        
        return self.rows
        
    }
}

/* Levenshtein Distance Algorithm
 * Calculates the minimum number of changes (distance) between two strings.
 */

public func slowlevenshtein(sourceString: String, target targetString: String) -> Int {
    
    let source = Array(sourceString.unicodeScalars)
    let target = Array(targetString.unicodeScalars)
    
    let (sourceLength, targetLength) = (source.count, target.count)
    
    var matrix = Array(repeating: Array(repeating: 0, count: sourceLength + 1), count: targetLength + 1)
    
    for x in  1..<targetLength {
        
        matrix[x][0] = matrix[x - 1][0] + 1
        
    }
    
    for y in 1..<sourceLength {
        
        matrix[0][y] = matrix[0][y - 1] + 1
        
    }
    
    for x in 1..<(targetLength + 1) {
        
        for y in 1..<(sourceLength + 1) {
            
            let penalty = source[y - 1] == target[x - 1] ? 0 : 1
            
            let (deletions, insertions, substitutions) = (matrix[x - 1][y] + 1, matrix[x][y - 1] + 1, matrix[x - 1][y - 1])
            
            matrix[x][y] = min3(a: deletions, b: insertions, c: substitutions + penalty)
            
        }
        
    }
    
    return matrix[targetLength][sourceLength]
    
}

public func levenshtein(sourceString: String, target targetString: String) -> Int {
    
    let source = Array(sourceString.unicodeScalars)
    let target = Array(targetString.unicodeScalars)
    
    let (sourceLength, targetLength) = (source.count, target.count)
    
    var distance = Array2D(columns: sourceLength + 1, rows: targetLength + 1)
    
    for x in 1...sourceLength {
        
        distance[x, 0] = x
        
    }
    
    for y in 1...targetLength {
        
        distance[0, y] = y
        
    }
    
    for x in 1...sourceLength {
        
        for y in 1...targetLength {
            
            if source[x - 1] == target[y - 1] {
                
                // no difference
                distance[x, y] = distance[x - 1, y - 1]
                
            } else {
                
                distance[x, y] = min3(
                    
                    // deletions
                    a: distance[x - 1, y] + 1,
                    // insertions
                    b: distance[x, y - 1] + 1,
                    // substitutions
                    c: distance[x - 1, y - 1] + 1
                    
                )
                
            }
            
        }
        
    }
    
    return distance[source.count, target.count]
    
}

public extension String {
    
    func getSlowLevenshtein(target: String) -> Int {
        
        return slowlevenshtein(sourceString: self, target: target)
        
    }
    
    func getLevenshtein(target: String) -> Int {
        

        return levenshtein(sourceString: self, target: target)
        
    }
    
}

