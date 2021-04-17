//
//  ContentView.swift
//  Snow
//
//  Created by Ted Östrem on 2021/4/9.
//

import SwiftUI
import RealityKit
import ARKit


extension ARAnchor: Identifiable {
    public var id: String {
        self.identifier.uuidString
    }
}

struct ContentView : View {
    var body: some View {
        ARSCNViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARSCNViewContainer: UIViewRepresentable {
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARSCNViewContainer
        
        init(_ parent: ARSCNViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let node = SCNNode()
            let shipScene = SCNScene(named: "art.scnassets/push_up.scn")!
            for childNode in shipScene.rootNode.childNodes {
                node.addChildNode(childNode)
            }
            return node
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "ImageAnchors", bundle: Bundle.main) else {
            print("No ImageAnchors found")
            return sceneView
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.init()
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = context.coordinator
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
