//
//  ContentView.swift
//  Snow
//
//  Created by Ted Östrem on 2021/4/9.
//

import SwiftUI
import RealityKit
import ARKit


struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        var parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
           print("Anchor added")
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            print("Anchor updated")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.enableTapGesture()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "ImageAnchors", bundle: Bundle.main) else {
            print("No ImageAnchors found")
            return arView
        }
        
        print(trackedImages)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.init()
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

extension ARView {

    
    func enableTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        guard let rayResult = self.ray(through: tapLocation) else { return }
        let results = self.scene.raycast(origin: rayResult.origin, direction: rayResult.direction)
        if let firstResult = results.first {
            // Raycast intersected with AR object
            // Place object ontop of existing AR object
            var position = firstResult.position
            position.y += 0.1/2
            placeCube(at: position)
        } else {
            // Raycast has not intersected with AR object
            // Place a new object on a real world surface if there is one detected
            let results = self.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
            if let firstResult = results.first {
                let position = simd_make_float3(firstResult.worldTransform.columns.3)
                placeCube(at: position)
            }
        }
        print("tap tap!")
    }
    
    func placeCube(at position: SIMD3<Float>) {
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: .white, roughness: 0.1, isMetallic: true)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.generateCollisionShapes(recursive: true)
        let anchorEntity = AnchorEntity(world: position)
        anchorEntity.addChild(modelEntity)
        self.scene.addAnchor(anchorEntity)
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
