//
//  ViewController.swift
//  AugmentedCamera
//
//  Created by 大山 貴史 on 2018/03/28.
//  Copyright © 2018年 Takafumi Oyama. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    private var drawingNodes = [SCNNode]()
    
    private var isTouching = false {
        didSet {
            cameraIcon.isHidden = !isTouching
        }
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var cameraIcon: UILabel!
    @IBOutlet var resetBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene = SCNScene()
        
        statusLabel.text = "Wait..."
        cameraIcon.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Private
    
    private func reset() {
        for node in drawingNodes {
            node.removeFromParentNode()
        }
        drawingNodes.removeAll()
    }
    
    private func isReadyForDrawing(trackingState: ARCamera.TrackingState) -> Bool {
        switch trackingState {
        case .normal:
            return true
        default:
            return false
        }
    }
    
    private func worldPositionForScreenCenter() -> SCNVector3 {
        let screenBounds = UIScreen.main.bounds
        let center = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        let centerVec3 = SCNVector3Make(Float(center.x), Float(center.y), 0.99)
        return sceneView.unprojectPoint(centerVec3)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //guard isTouching else {return}
        //guard let currentDrawing = drawingNodes.last else {return}
        
        if let camera = sceneView.pointOfView {
            for node in sceneView.scene.rootNode.childNodes {
                node.eulerAngles.x = camera.eulerAngles.x
                node.eulerAngles.y = camera.eulerAngles.y
                node.eulerAngles.z = camera.eulerAngles.z
            }
        }
    }
    
    // MARK: - ARSessionObserver
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("\(self.classForCoder)/\(#function), error: " + error.localizedDescription)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("trackingState: \(camera.trackingState)")
        
        let state = camera.trackingState
        let isReady = isReadyForDrawing(trackingState: state)
        statusLabel.text = isReady ? "Touch the screen to draw." : "Wait. " + state.description
    }
    
    // MARK: - Touch Handlers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let frame = sceneView.session.currentFrame else {return}
        guard isReadyForDrawing(trackingState: frame.camera.trackingState) else {return}
        
        // バッファからキャプチャ画像の取得
        let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
        let temporaryContext = CIContext(options: nil)
        let captureCGImage = temporaryContext.createCGImage(
            ciImage,
            from: CGRect(x: 0,
                         y: 0,
                         width: CGFloat(CVPixelBufferGetWidth(frame.capturedImage)),
                         height: CGFloat(CVPixelBufferGetHeight(frame.capturedImage))))
        let captureImage = UIImage(cgImage: captureCGImage!)
        
        // 平面の作成
        let imageNode = SCNNode()
        let imageNodeWidth = 0.13
        let plane = SCNPlane(width: CGFloat(imageNodeWidth), height: CGFloat(imageNodeWidth)*captureImage.size.height/captureImage.size.width)
        imageNode.geometry = plane
        plane.firstMaterial?.diffuse.contents = captureImage
        plane.cornerRadius = 5
        
        let position = SCNVector3(x: 0, y: 0, z: -0.1)
        if let camera = sceneView.pointOfView {
            imageNode.position = camera.convertPosition(position, to: nil)
            
            let rotateX = SCNMatrix4MakeRotation(camera.eulerAngles.x * Float.pi / 180, 1, 0, 0)
            let rotateY = SCNMatrix4MakeRotation(camera.eulerAngles.y * Float.pi / 180, 0, 1, 0)
            let rotateZ = SCNMatrix4MakeRotation((camera.eulerAngles.z+90) * Float.pi / 180, 0, 0, 1)
            
            imageNode.pivot = SCNMatrix4Mult(SCNMatrix4Mult(rotateX, rotateY), rotateZ)
        }
        
        sceneView.scene.rootNode.addChildNode(imageNode)
        drawingNodes.append(imageNode)
        
        statusLabel.text = "Move your device!"
        
        isTouching = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        statusLabel.text = "Touch the screen to draw."
    }
    
    // MARK: - Actions
    
    @IBAction func resetBtnTapped(_ sender: UIButton) {
        reset()
    }
}

