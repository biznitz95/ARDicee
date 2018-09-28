//
//  ViewController.swift
//  ARDicee
//
//  Created by Bizet Rodriguez on 9/26/18.
//  Copyright © 2018 Bizet Rodriguez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // We got vertical now
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {fatalError("Failed to get first touch")}
        
        let touchLocation = touch.location(in: sceneView)
        
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        // Add Dice
        if let hitResult = results.first {
            // Create a new scened
            let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

            guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else {fatalError("Error finding child node Dice")}

            diceNode.position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                hitResult.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)

            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
        
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = CGFloat.random(in: 1...5) * (CGFloat.pi/2.0) * CGFloat(5)
        //            let randomY =
        let randomZ = CGFloat.random(in: 1...5) * (CGFloat.pi/2.0) * CGFloat(5)
        
        dice.runAction(SCNAction.rotateBy(x: randomX, y: 0, z: randomZ, duration: 0.5))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2.0, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        }
        else {
            return
        }
    }


    @IBAction func rollButtonPressed(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
}
