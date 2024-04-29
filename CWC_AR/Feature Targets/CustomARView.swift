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


class CustomARView: ARView, ARSessionDelegate {
    var placedItem: Entity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    func setup() {
        MetalLibLoader.initializeMetal()
    }
    
    func startApplyingForce(direction: Direction) {
        moveItem(direction: direction)
    }
    
    func stopApplyingForce() {
        moveItem(direction: .stay)
    }
    
    func dragItem(translation: CGSize) {
        guard let _ = placedItem else { return }
        let translationVector = SIMD3<Float>(
            x: Float(translation.width) * 0.0001,
            y: Float(-translation.height) * 0.0001,
            z: 0
        )
        
        placedItem?.transform.translation += translationVector
    }
    
    func pinchItem(magnitude: CGFloat) {
        guard let _ = placedItem else { return }
        var zTranslation: CGFloat
        if magnitude > 1 {
            zTranslation = -magnitude * 0.01
        } else if magnitude < 1 {
            zTranslation = (1 - magnitude) * 0.1
        } else {
            return
        }
        placedItem?.transform.translation.z += Float(zTranslation)
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
                case .placeBall:
                    self?.placeBall()
                case .removeAllAnchors:
                    self?.scene.anchors.removeAll()
                    self?.placedItem = nil
                case .placeItem(item: let item):
                    self?.placeItem(item: item)
                case .moveItem(direction: let direction):
                    self?.moveItem(direction: direction)
                case .startApplyingForce(direction: let direction):
                    self?.startApplyingForce(direction: direction)
                case .stopApplyingForce:
                    self?.stopApplyingForce()
                case .translateItem(translation: let translation):
                    self?.dragItem(translation: translation)
                case .pinchItem(magnitude: let magnitude):
                    self?.pinchItem(magnitude: magnitude)
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
    
    func placeBall() {
        if let existingEntity = placedItem {
            guard let existingAnchor = existingEntity.anchor else { return }
            existingAnchor.removeChild(placedItem!)
            
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.generateCollisionShapes(recursive: true)
            // Membuat komponen fisik
            entity.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                      material: .default,
                                                        mode: .dynamic)
            placedItem = entity
            // Add the new entity to the same anchor as the existing one
            existingAnchor.addChild(placedItem!)
        } else {
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.generateCollisionShapes(recursive: true)
            // Membuat komponen fisik
            entity.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                      material: .default,
                                                        mode: .dynamic)
            
            placedItem = entity
            
            let planeAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .zero))
            planeAnchor.addChild(placedItem!)
            scene.addAnchor(planeAnchor)
        }
    }
    
    func placeItem(item: String) {
        if let existingEntity = placedItem {
            // Retrieve the anchor of the existing entity
            guard let existingAnchor = existingEntity.anchor else {
                // If there's no anchor for the existing item (unlikely scenario), return
                return
            }
            existingAnchor.removeChild(placedItem!)
            
            guard let entity = try? ModelEntity.load(named: item) else { return }
            
            // Add the new entity to the same anchor as the existing one
            existingAnchor.addChild(entity)
            
            // Update the reference to the placed item
            placedItem = entity
        } else {
            guard let entity = try? ModelEntity.load(named: item) else { return }
            let planeAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .zero))
            planeAnchor.addChild(entity)
            scene.addAnchor(planeAnchor)
            
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

//struct EntityComponent: Component {
//    static let query = EntityQuery(where: .has(EntityComponent.self))
//    
//    var direction: Direction?
//}
//
//class PhysicSystem: System {
//    required init(scene: RealityKit.Scene) { }
//    
//    func update(context: SceneUpdateContext) {
//        if let entity = context.scene.performQuery(EntityComponent.query).first {
//            move(entity: entity)
//        }
//    }
//    
//    private func move(entity: Entity) {
//        guard let entityState = entity.components[EntityComponent.self],
//              let physicBody = entity as? HasPhysicsBody else { return }
//        
//        if let direction = entityState.direction?.vector {
//            physicBody.applyLinearImpulse(direction, relativeTo: nil)
//        }
//    }
//}
