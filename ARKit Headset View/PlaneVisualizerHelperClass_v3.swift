//
//  PlaneVisualizerHelperClass.swift
//  AR Text
//
//  Created by Hanley Weng on 1/7/18.
//  Copyright © 2018 CompanyName. All rights reserved.
//

// Sourced via jaxony at: https://github.com/jaxony/ar-scene-plane-geometry-demo // Note: Sometimes bugs out, but sufficient for debugging purposes.

import Foundation
import ARKit

class PlaneVisualizerHelperClass {
    
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    private var currPlaneId: Int = 0
    
    func createPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
        // Note: ARSCNPlaneGeometry requires iOS 11.3 +
        let scenePlaneGeometry = ARSCNPlaneGeometry(device: metalDevice!)
        scenePlaneGeometry?.update(from: planeAnchor.geometry)
        
        // ~
        scenePlaneGeometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(planeAnchor.extent.x / 0.2 , planeAnchor.extent.z / 0.2 , 0) // Every 10 cm
        
        let planeNode = SCNNode(geometry: scenePlaneGeometry)
        planeNode.name = "\(currPlaneId)"
        planeNode.opacity = 0.25
        if planeAnchor.alignment == .horizontal {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        } else {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        }
        currPlaneId += 1
        return planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return } // only care about detected planes (i.e. `ARPlaneAnchor`s)
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first
            else { return }
        
        // guard let planeAnchor = anchor as? ARPlaneAnchor else { return } // only care about detected planes (i.e. `ARPlaneAnchor`s)
        
        planeNode.removeFromParentNode()
        let planeNode2 = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode2)
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return } // only care about detected planes (i.e. `ARPlaneAnchor`s)
        guard let planeNode = node.childNodes.first else { return }
        
        print("Removing plane anchor")
        planeNode.removeFromParentNode()
    }
}
