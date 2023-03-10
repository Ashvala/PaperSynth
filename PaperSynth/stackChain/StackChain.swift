import AudioKit
import AudioKitUI
import Foundation
import UIKit

class StackChain {

    /**
     This method compiles a set of stackChainUnits into something that can be played via AudioKit
     
     - parameters:
         - widgetList:
         An Array<String> containing a set of keywords.
     
     - returns:
        nodesList:
        a list of stackChainUnits
     */
    func createObjects(widgetList: [String]) -> [stackChainUnit] {
        print("widgetsList: \(widgetList)")
        // From this point onwards, we assume that the first point in any list is just a node and everything else is an output.
        var nodesList: [stackChainUnit] = []

        for i in widgetList {
            switch i {
            case "osc":
                nodesList.append(stackChainUnit(name: "osc", type: .oscil, canInput: false))
            case "del":
                nodesList.append(stackChainUnit(name: "delay", type: .delay, canInput: true))
            default:
                print("Not appending this. Unrecognized keyword")
            }
        }
        return nodesList
    }
    
    /**
     This method compiles a set of stackChainUnits into something that can be played via AudioKit
     
     - parameters:
        - nodesList:
        All the stackChain nodes you will be connecting
     */

    func compileModel(nodesList: [stackChainUnit]) -> Mixer {
        let objList = nodesList
        print("\(objList.count) objects in the list")
        let mixer = Mixer()
        var myElements: [Node] = []
        for (index, element) in objList.enumerated() {
            if index + 1 != objList.count {
                var currNode: Node
                var nextNode: Node
                print("connecting \(index) to \(index + 1)")
                print("elements involved are: \(element), \(objList[index + 1])")
                // get node type
                let nodeType = element.getType()
                let nextNodeType = objList[index + 1].getType()
                // check if current node needs input
                if element.canInput {
                    // if it does, get the node from the previous element
                    currNode = myElements[myElements.count - 1]
                } else {
                    // if it doesn't, create a new node
                    currNode = makeNode(data: "\(nodeType)")
                }
                // check if next node needs input
                if objList[index + 1].canInput {
                    // if it does, create a new node
                    
                    nextNode = makeNode(data: "\(nextNodeType)", inputNode: currNode)
                } else {
                    // if it doesn't, create a new node
                    nextNode = makeNode(data: "\(nodeType)")
                }
                
                // check if current node is oscil and set default values
                if nodeType == .oscil {
                    currNode.parameters[0].value = 880.0
                }
                // check if next node is oscil and set default values
                if nextNodeType == .oscil {
                    nextNode.parameters[0].value = 880.0
                }
                // add both nodes to myElements
                myElements.append(currNode)
                myElements.append(nextNode)
            }
        }
        // take final node in myElements and connect it to the mixer
        let finalNode = myElements[myElements.count - 1]
        mixer.addInput(finalNode)
        // iterate through myElements and set each node to play
        for element in myElements {
            element.play()
        }
        mixer.play()
        return mixer
    }
    
}
