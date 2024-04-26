//
//  CustomARView.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 24/04/24.
//

import ARKit
import RealityKit
import SwiftUI
import Combine


class CustomARView: ARView {
    //    var placedEntities: [String: Entity] = [:]
    var placedItem: Entity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    func startApplyingForce(direction: Direction) {
        moveItem(direction: direction)
    }
    
    func stopApplyingForce() {
        moveItem(direction: .stay)
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        
        subscribeToActionStream()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribeToActionStream() {
        ARManager.shared.actionStream
            .sink { [weak self] action in
                switch action {
                    case .placeBlock(let color):
                        self?.placeBlock(ofColor: color)
                    case .removeAllAnchors:
                        self?.scene.anchors.removeAll()
                    case .placeItem(item: let item):
                        self?.placeItem(item: item)
                    case .moveItem(direction: let direction):
                        self?.moveItem(direction: direction)
                    case .startApplyingForce(direction: let direction):
                        self?.startApplyingForce(direction: direction)
                    case .stopApplyingForce:
                        self?.stopApplyingForce()
                }
            }
                .store(in: &cancellables)
    }
        
        func configurationExamples() {
            // Track the device relative to it's environment
            let configuration = ARWorldTrackingConfiguration()
            session.run(configuration)
            
            //belum support semua daerah terakhir baru US
            let _ = ARGeoTrackingConfiguration()
            
            // track faces in the scene
            let _ = ARFaceTrackingConfiguration()
            
            //track bodies in the scene
            let _ = ARBodyTrackingConfiguration()
        }
        
        func anchorExamples() {
            // Attach anchor at specific coordinates in the Iphone-centered coordinate system
            let coordinateAnchor = AnchorEntity()
            
            //Attach anchors to detect planes (Lebih bagus kalau pakai LiDAR)
            let _ = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .zero))
            let _ = AnchorEntity(.plane(.vertical, classification: .any, minimumBounds: .zero))
            
            //Attach anchors to the tracked body parts such as face
            let _ = AnchorEntity(.face)
            
            // Attach anchors to tracked images, such as markers or visual code
            let _ = AnchorEntity(.image(group: "group", name: "name"))
            
            // Add anchors to the scene
            scene.addAnchor(coordinateAnchor)
        }
        
        func entityExamples() {
            // Load entity from usdz files
            let _ = try? Entity.load(named: "usdzFileName")
            
            // Load entity from reality file
            let _ = try? Entity.load(named: "RealityFileName")
            
            // Generate entity with code
            let box = MeshResource.generateBox(size: 1)
            let entity = ModelEntity(mesh: box)
            
            // Add entity to anchor , so its placed on the scene
            let anchor = AnchorEntity()
            anchor.addChild(entity)
        }
        
        func placeBlock(ofColor color: Color) {
            scene.anchors.removeAll()
            placedItem = nil
            
            let block = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: UIColor(color), isMetallic: true)
            let entity = ModelEntity(mesh: block, materials: [material])
            
            //        let anchor = AnchorEntity(world: SIMD3<Float>(x:0, y: 0, z: 0))
            //        anchor.addChild(entity)
            
            let planeAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.5, 0.5]))
            planeAnchor.addChild(entity)
            
            scene.addAnchor(planeAnchor)
            placedItem = entity
        }
        
        func placeItem(item: String) {
            if let existingEntity = placedItem {
                // Retrieve the anchor of the existing entity
                guard let existingAnchor = existingEntity.anchor else {
                    // If there's no anchor for the existing item (unlikely scenario), return
                    return
                }
                existingAnchor.removeChild(existingEntity)
                // Load the new entity
                guard let entity = try? ModelEntity.load(named: item) else { return }
                
                // Add the new entity to the same anchor as the existing one
                existingAnchor.addChild(entity)
                
                // Update the reference to the placed item
                placedItem = entity
            } else {
                // If there's no existing entity, place the new item normally
                guard let entity = try? ModelEntity.load(named: item) else { return }
                let planeAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.5, 0.5]))
                planeAnchor.addChild(entity)
                scene.addAnchor(planeAnchor)
                
                // Update the reference to the placed item
                placedItem = entity
            }
        }
        
        func moveItem(direction: Direction) {
            guard let _ = placedItem else { return }
            
            var translation = SIMD3<Float>()
            switch direction {
            case .forward:
                translation.z -= 0.01
            case .backward:
                translation.z += 0.01
            case .left:
                translation.x -= 0.01
            case .right:
                translation.x += 0.01
            case .up:
                translation.y += 0.01
            case .down:
                translation.y -= 0.01
            case .stay:
                break
            }
            
            placedItem?.transform.translation += translation
        }
        
    }
