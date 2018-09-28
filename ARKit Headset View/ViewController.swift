//
//  ViewController.swift
//  ARKit Headset View
//
//  Created by Hanley Weng on 8/7/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sceneViewLeft: ARSCNView!
    @IBOutlet weak var sceneViewRight: ARSCNView!
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!
    
    // Parametres
    let viewBackgroundColor : UIColor = UIColor.black // UIColor.white
    
    var arScnStereoViewClass = ARSCNStereoViewClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        // Set the scene to the view
//        sceneView.scene = scene
        
        // Setup SceneView
        arScnStereoViewClass.viewDidLoad_setup(iSceneView: sceneView, iSceneViewLeft: sceneViewLeft, iSceneViewRight: sceneViewRight, iImageViewLeft: imageViewLeft, iImageViewRight: imageViewRight)
        // Scene/View setup
        self.view.backgroundColor = viewBackgroundColor
        
        // App Setup
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration // Run the view's session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.arScnStereoViewClass.updateFrame()
        }
    }
    
}
