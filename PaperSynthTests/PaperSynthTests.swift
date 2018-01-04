//
//  PaperSynthTests.swift
//  PaperSynthTests
//
//  Created by Ashvala Vinay on 12/8/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import XCTest
@testable import PaperSynth
import AudioKit

class PaperSynthTests: XCTestCase {
    // swiftlint:disable force_cast
    
    func attemptConnect(){
        // create an oscil and delay
        var objects = [PSOscil(), PSDelay(), PSMixer()]
        
        for (index, element) in objects.enumerated() {
            if index + 1 != objList.count {
                print("connecting \(index) to \(index + 1)")
                print("elements involved are: \(element), \(objList[index + 1])")
                (element.getUnit() as! AKNode).setOutput(to: objList[index + 1].getUnit() as! AKInput)
            }
        }
        
    }
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        self.attemptConnect()
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
