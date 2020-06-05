//
//  ViewController.swift
//  ARFaceDemo
//
//  Created by Mac on 2020/6/4.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
class EmojiBlingViewController: UIViewController {

    var arscnView = ARSCNView()

    let fetures = ["nose", "leftEye", "rightEye", "mouth", "hat"]
    let fetureIndices = [[9], [1064], [42], [24,25], [20]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        arscnView.frame = view.frame
        view.addSubview(arscnView)
        arscnView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.arscnView.addGestureRecognizer(tapGesture)
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("对不起，当前设备不具备原深感镜头")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        arscnView.session.run(configuration, options: .resetSceneReconstruction)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        arscnView.session.pause()
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature, indices) in zip(fetures, fetureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? EmojiNode
            let vertices = indices.map{ anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
            
            switch feature {
            case "leftEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            case "rightEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            default:
                break
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("tap")
        let location = sender.location(in: self.arscnView)
        let results = self.arscnView.hitTest(location, options: nil)
        if let result = results.first,
            let node = result.node as? EmojiNode{
            node.next()
        }
    }

}

extension EmojiBlingViewController:ARSCNViewDelegate{


    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = arscnView.device,
            let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        let node = SCNNode(geometry: faceGeometry)
        
        node.geometry?.firstMaterial?.fillMode = .fill
            
        //将整个面部替换成一张图片
//        let material = faceGeometry?.firstMaterial
//        material?.diffuse.contents = UIImage.init(named: "eye")
//        material?.lightingModel = .physicallyBased
        
        node.geometry?.firstMaterial?.transparency = 0
        
        let leftEyeNode = EmojiNode(with: ["eye"])
        leftEyeNode.name = "leftEye"
        leftEyeNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(180.0))
        node.addChildNode(leftEyeNode)
        
        

        let rightEyeNode = EmojiNode(with: ["eye"])
        rightEyeNode.name = "rightEye"
//        rightEyeNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(180.0))
        node.addChildNode(rightEyeNode)
        
        updateFeatures(for: node, using: faceAnchor)
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
    
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
    

}

