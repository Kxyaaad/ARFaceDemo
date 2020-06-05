//
//  EmojiNode.swift
//  ARFaceDemo
//
//  Created by Mac on 2020/6/4.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import SceneKit

class EmojiNode: SCNNode {
    var options: [String]
    var index = 0
    
    init(with options:[String], width: CGFloat = 0.06, height: CGFloat = 0.06) {
        self.options = options
        
        super.init()
        
        let plane = SCNPlane(width: width, height: height)
        
        plane.firstMaterial?.diffuse.contents = UIImage.init(named: options.first ?? " ")
        plane.firstMaterial?.isDoubleSided = true
        
        geometry = plane
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiNode {
    func updatePosition(for vectors:[vector_float3]) {
        let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
        position = SCNVector3(newPos)
    }
    
    func next() {
        index = (index + 1) % options.count
        
        if let plane = geometry as? SCNPlane {
            plane.firstMaterial?.diffuse.contents = options[index].image()
            plane.firstMaterial?.isDoubleSided = true
        }
    }
    

}
