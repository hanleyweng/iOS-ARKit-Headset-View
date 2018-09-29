//
//  ARSCNViewHelperClass.swift
//  ARKit Headset View
//
//  Created by Hanley Weng on 1/6/18.
//  Copyright © 2018 CompanyName. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

// 2018-09-27 Note: Running app without being connected to XCode may result in smoother performance.

class ARSCNStereoViewClass {
    
    var sceneView: ARSCNView!
    var sceneViewLeft: ARSCNView!
    var sceneViewRight: ARSCNView!
    
    var imageViewLeft: UIImageView!
    var imageViewRight: UIImageView!
    
    let eyeCamera : SCNCamera = SCNCamera()
    
    // Parametres
    let _HEADSET_IS_PASSTHROUGH_VS_SEETHROUGH = true // Pass-through uses a camera to show the outside world (like Merge VR, Gear VR). See-through headsets allow your eyes to see the real world (Aryzon, Hololens, Northstar).
    let _CAMERA_IS_ON_LEFT_EYE = false
    let interpupilaryDistance : Float = 0.066 // This is the value for the distance between two pupils (in metres). The Interpupilary Distance (IPD).
    
    /*
     SET eyeFOV and cameraImageScale. UNCOMMENT any of the below lines to change FOV:
     */
    //    let eyeFOV = 38.5; var cameraImageScale = 1.739; // (FOV: 38.5 ± 2.0) Brute-force estimate based on iPhone7+
    let eyeFOV = 60; var cameraImageScale = 3.478; // Calculation based on iPhone7+ // <- Works ok for cheap mobile headsets. Rough guestimate.
    //    let eyeFOV = 90; var cameraImageScale = 6; // (Scale: 6 ± 1.0) Very Rough Guestimate.
    //    let eyeFOV = 120; var cameraImageScale = 8.756; // Rough Guestimate.
    
    func viewDidLoad_setup(iSceneView: ARSCNView, iSceneViewLeft: ARSCNView, iSceneViewRight: ARSCNView, iImageViewLeft: UIImageView, iImageViewRight: UIImageView) {
        
        sceneView = iSceneView
        sceneViewLeft = iSceneViewLeft
        sceneViewRight = iSceneViewRight
        imageViewLeft = iImageViewLeft
        imageViewRight = iImageViewRight
        
        ////////////////////////////////////////////////////////////////
        // Prevent Auto-Lock
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Prevent Screen Dimming
        let currentScreenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = currentScreenBrightness
        
        ////////////////////////////////////////////////////////////////
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // Set the scene to the view
        sceneView.scene = scene
        
        // Tweak World Origin so it's between Eyes (Default is initial Camera Position)
        // sceneView.session.setWorldOrigin(relativeTransform: <#T##simd_float4x4#>) // Todo Later.
        
        ////////////////////////////////////////////////////////////////
        // LIGHTING
         // sceneView.autoenablesDefaultLighting = true
        
        // NOTE: LIGHTING requires additional power.
        // Priority 1. Directional Light for Shadows.
        // Priority 2. Ambient Light.
        
        // NOTE: Shadows are only cast by spot (cone) or directional lights (not point/omni). - https://developer.apple.com/documentation/scenekit/scnlight/1523816-castsshadow
        
        // Create a directional light node with shadow
        let directionalNode = SCNNode()
        directionalNode.light = SCNLight()
        directionalNode.light?.type = SCNLight.LightType.directional
        directionalNode.light?.color = UIColor.white
        directionalNode.light?.intensity = 2000

        directionalNode.light?.castsShadow = true // to cast shadow
        //        directionalNode.light?.shadowMode = .deferred  // to render shadow in transparent plane
        //        directionalNode.light?.automaticallyAdjustsShadowProjection = true // ?
        //        directionalNode.light?.shadowSampleCount = 64 //remove flickering of shadow and soften shadow
        //        directionalNode.light?.shadowMapSize = CGSize(width: 2048, height: 2048) //sharpen or detail shadow
        //        directionalNode.position = SCNVector3(x: 0,y: 0,z: 0)

        sceneView.pointOfView?.addChildNode(directionalNode)
        
//        // Create a spot light node with shadow
//        let spotLight = SCNLight()
//        spotLight.type = .spot
//        spotLight.spotInnerAngle = 45
//        spotLight.spotOuterAngle = 90
//        spotLight.intensity = 2000
//        spotLight.castsShadow = true // to cast shadow
//        let spotLighNode = SCNNode()
//        spotLighNode.light = spotLight
//
//        sceneView.pointOfView?.addChildNode(spotLighNode)

        
        // Create a ambient light
        //        let ambientLight = SCNNode()
        //        ambientLight.light = SCNLight()
        //        ambientLight.light?.color = UIColor.white
        //        ambientLight.light?.type = SCNLight.LightType.ambient
        //        ambientLight.light?.intensity = 500
        //        ambientLight.position = SCNVector3(x: 0,y: 0,z: 0)
        //
        //        scene.rootNode.addChildNode(ambientLight)
        
        
        ////////////////////////////////////////////////////////////////
        // Set Debug Options
        // sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, .showFeaturePoints]
        
        // Scene setup
        sceneView.isHidden = true
        
        // Set Clear Background for See-Through Headsets
        if !_HEADSET_IS_PASSTHROUGH_VS_SEETHROUGH {
            sceneView.scene.background.contents = UIColor.clear
        }
        
        ////////////////////////////////////////////////////////////////
        // Set up Left-Eye SceneView
        sceneViewLeft.scene = scene
        sceneViewLeft.showsStatistics = sceneView.showsStatistics
        sceneViewLeft.isPlaying = true
        
        // Set up Right-Eye SceneView
        sceneViewRight.scene = scene
        sceneViewRight.showsStatistics = sceneView.showsStatistics
        sceneViewRight.isPlaying = true
        
        ////////////////////////////////////////////////////////////////
        // Setup ImageViews - for rendering Camera Image
        self.imageViewLeft.clipsToBounds = true
        self.imageViewLeft.contentMode = UIView.ContentMode.center
        self.imageViewRight.clipsToBounds = true
        self.imageViewRight.contentMode = UIView.ContentMode.center
        
        ////////////////////////////////////////////////////////////////
        // Note: iOS 11.3 has introduced ARKit at 1080p, up for 720p
        // Update Camera Image Scale - according to iOS 11.3 (ARKit 1.5)
        if #available(iOS 11.3, *) {
            print("iOS 11.3 or later")
            cameraImageScale = cameraImageScale * 1080.0 / 720.0
        } else {
            print("earlier than iOS 11.3")
        }
        
        ////////////////////////////////////////////////////////////////
        // Create CAMERA
        eyeCamera.zNear = 0.001
        /*
         Note:
         - camera.projectionTransform was not used as it currently prevents the simplistic setting of .fieldOfView . The lack of metal, or lower-level calculations, is likely what is causing mild latency with the camera.
         - .fieldOfView may refer to .yFov or a diagonal-fov.
         - in a STEREOSCOPIC layout on iPhone7+, the fieldOfView of one eye by default, is closer to 38.5°, than the listed default of 60°
         */
        eyeCamera.fieldOfView = CGFloat(eyeFOV)
    }
    
    /* Called constantly, at every Frame */
    func updateFrame() {
        updatePOVs()
        if _HEADSET_IS_PASSTHROUGH_VS_SEETHROUGH {
            updateImages()
        }
    }
    
    func updatePOVs() {
        /////////////////////////////////////////////
        // CREATE POINT OF VIEWS
        let pointOfView : SCNNode = SCNNode()
        pointOfView.transform = (sceneView.pointOfView?.transform)!
        pointOfView.scale = (sceneView.pointOfView?.scale)!
        // Create POV from Camera
        pointOfView.camera = eyeCamera
        
        let sceneViewMain = _CAMERA_IS_ON_LEFT_EYE ? sceneViewLeft! : sceneViewRight!
        let sceneViewScnd = _CAMERA_IS_ON_LEFT_EYE ? sceneViewRight! : sceneViewLeft!
        
        //////////////////////////
        // Set PointOfView of Main Camera Eye
        
        sceneViewMain.pointOfView = pointOfView

        //////////////////////////
        // Set PointOfView of Virtual Second Eye
        
        // Clone pointOfView for Right-Eye SceneView
        let pointOfView2 : SCNNode = (sceneViewMain.pointOfView?.clone())! // Note: We clone the pov of sceneViewLeft here, not sceneView - to get the correct Camera FOV.
        
        // Determine Adjusted Position for Right Eye
        
        // Get original orientation. Co-ordinates:
        let orientation : SCNQuaternion = pointOfView2.orientation // not '.worldOrientation'
        // Convert to GLK
        let orientation_glk : GLKQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        
        // Set Transform Vector (this case it's the Positive X-Axis.)
        let xdir : Float = _CAMERA_IS_ON_LEFT_EYE ? 1.0 : -1.0
        let alternateEyePos : GLKVector3 = GLKVector3Make(xdir, 0.0, 0.0) // e.g. This would be GLKVector3Make(- 1.0, 0.0, 0.0) if we were manipulating an eye to the 'left' of the source-View. Or, in the odd case we were manipulating an eye that was 'above' the eye of the source-view, it'd be GLKVector3Make(0.0, 1.0, 0.0).
        
        // Calculate Transform Vector
        let transformVector = getTransformForNewNodePovPosition(orientationQuaternion: orientation_glk, eyePosDirection: alternateEyePos, magnitude: interpupilaryDistance)
        
        // Add Transform to PointOfView2
        pointOfView2.localTranslate(by: transformVector) // works - just not entirely certain
        
        // Set PointOfView2 for SceneView-RightEye
        sceneViewScnd.pointOfView = pointOfView2
    }
    
    /**
     Used by POVs to ensure correct POVs.
     
     For EyePosVector e.g. This would be GLKVector3Make(- 1.0, 0.0, 0.0) if we were manipulating an eye to the 'left' of the source-View. Or, in the odd case we were manipulating an eye that was 'above' the eye of the source-view, it'd be GLKVector3Make(0.0, 1.0, 0.0).
     */
    private func getTransformForNewNodePovPosition(orientationQuaternion: GLKQuaternion, eyePosDirection: GLKVector3, magnitude: Float) -> SCNVector3 {
        
        // Rotate POV's-Orientation-Quaternion around Vector-to-EyePos.
        let rotatedEyePos : GLKVector3 = GLKQuaternionRotateVector3(orientationQuaternion, eyePosDirection)
        // Convert to SceneKit Vector
        let rotatedEyePos_SCNV : SCNVector3 = SCNVector3Make(rotatedEyePos.x, rotatedEyePos.y, rotatedEyePos.z)
        
        // Multiply Vector by magnitude (interpupilary distance)
        let transformVector : SCNVector3 = SCNVector3Make(rotatedEyePos_SCNV.x * magnitude,
                                                          rotatedEyePos_SCNV.y * magnitude,
                                                          rotatedEyePos_SCNV.z * magnitude)
        
        return transformVector
        
    }
    
    func updateImages() {
        ////////////////////////////////////////////
        // RENDER CAMERA IMAGE
        /*
         Note:
         - as camera.contentsTransform doesn't appear to affect the camera-image at the current time, we are re-rendering the image.
         - for performance, this should ideally be ported to metal
         */
        
        // Clear Original Camera-Image
        sceneView.scene.background.contents = UIColor.clear // This sets a transparent scene bg for all sceneViews - as they're all rendering the same scene.
        
        // Read Camera-Image
        let pixelBuffer : CVPixelBuffer? = sceneView.session.currentFrame?.capturedImage
        if pixelBuffer == nil { return }
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer!)
        // Convert ciimage to cgimage, so uiimage can affect its orientation
        let context = CIContext(options: nil)
        let cgimage = context.createCGImage(ciimage, from: ciimage.extent)
        
        // Determine Camera-Image Scale
        let scale_custom : CGFloat = CGFloat(cameraImageScale)
        
        // Determine Camera-Image Orientation
        let imageOrientation : UIImage.Orientation = (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft) ? UIImage.Orientation.down : UIImage.Orientation.up
        
        // Display Camera-Image
        let uiimage = UIImage(cgImage: cgimage!, scale: scale_custom, orientation: imageOrientation)
        self.imageViewLeft.image = uiimage
        self.imageViewRight.image = uiimage
    }
    
}
