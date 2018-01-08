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
        // From this point onwards, we assume that the first point in any list is just a node and everything else is an output.
        var nodesList: [stackChainUnit] = []

        for i in widgetList {
            switch i {
            case "osc":
                nodesList.append(stackChainUnit(name: "osc", type: .oscil, canInput: false))
            case "del":
                nodesList.append(stackChainUnit(name: "delay", type: .delay, canInput: true))
            case "rev":
                nodesList.append(stackChainUnit(name: "reverb", type: .reverb, canInput: true))
            case "mic":
                nodesList.append(stackChainUnit(name: "mic", type: .mic, canInput: false))
            case "mixer":
                nodesList.append(stackChainUnit(name: "mic", type: .mixer, canInput: true))
            case "eq":
                nodesList.append(stackChainUnit(name: "eq", type: .eq, canInput: true))
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

    func compileModel(nodesList: [stackChainUnit]) {
        var objList = nodesList
        objList.append(stackChainUnit(name: "mixer", type: .mixer, canInput: false))
        for (index, element) in objList.enumerated() {
            if index + 1 != objList.count {
                print("connecting \(index) to \(index + 1)")
                print("elements involved are: \(element), \(objList[index + 1])")
                (element.unit.getNode()).setOutput(to: objList[index + 1].unit.getNode() as! AKInput)
            }
        }
        let generator = (objList[0].unit.getNode() as! AKToggleable)
        let f_mixer = (objList[objList.count - 1].unit.getNode() as! AKMixer)
        f_mixer.volume = 0.8
        AKSettings.audioInputEnabled = true
        AKSettings.useBluetooth = true
        AudioKit.output = f_mixer
        AudioKit.start()
        generator.start()
    }
}
