//
//  ViewController.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/4/20.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    var sceneView: ARSCNView! //场景
    var planes = [UUID:Plane]() //字典，存储场景中当前渲染的所有平面
    var sessionConfig: ARConfiguration!//会话配置
    var tipLabel = UILabel() //提示标签
    var vetecorLabel = UILabel() //位置信息
    var hasShowAlert = false//是否已经展示过扫码后的提示信息

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupMySubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSession()
        if !hasShowAlert {
            hasShowAlert = true
            let alertView = UIAlertController(title: "提示", message: "请站在原地对准地面，我们将为您加载导航", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (cancelAction) in
                
            }
            alertView.addAction(cancelAction)
            //        alertView.show(self, sender: nil)
            self.present(alertView, animated: true) {
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sessionCurrentFrame()
    }
    
    /// 初始化子视图
    private func setupMySubView() {
        self.view.addSubview(tipLabel)
        tipLabel.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 30)
        tipLabel.textColor = UIColor.blue
        
        self.view.addSubview(vetecorLabel)
        vetecorLabel.frame = CGRect(x: 0, y: tipLabel.frame.origin.y + tipLabel.frame.size.height + 5, width: self.view.frame.size.width, height: 300)
        vetecorLabel.numberOfLines = 0
        vetecorLabel.textColor = UIColor.blue
    }
    
    //初始化场景
    private func setupScene() {
        sceneView = ARSCNView()
        sceneView.frame = self.view.frame
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    // 配置会话
    private func setupSession() {
        if ARWorldTrackingConfiguration.isSupported {//判断是否支持6个自由度
            let worldTracking = ARWorldTrackingConfiguration()
            worldTracking.planeDetection = .horizontal//平面检测
            worldTracking.isLightEstimationEnabled = true //光估计
            sessionConfig = worldTracking
        }
        else{
            let orientationTracking = AROrientationTrackingConfiguration()//3DOF
            sessionConfig = orientationTracking
        }
        sceneView.session.run(sessionConfig)
    }
    
    //手机的位姿
    private func sessionCurrentFrame() {
        if let currentFrame = sceneView.session.currentFrame {
            
            var transform = currentFrame.camera.transform
            var infoStr = String()
            infoStr.append("在世界坐标系中定义摄像机旋转和平移的变换矩阵:\n")
            for index in 0..<4 {
                
                if index == 0 {
                    infoStr.append("\(transform.columns.0.x) , \(transform.columns.0.y) , \(transform.columns.0.z) , \(transform.columns.0.w)")
                }
                else if index == 1 {
                    infoStr.append("\n \(transform.columns.1.x) , \(transform.columns.1.y) , \(transform.columns.1.z) , \(transform.columns.1.w)")
                }
                else if index == 2 {
                    infoStr.append("\n \(transform.columns.2.x) , \(transform.columns.2.y) , \(transform.columns.2.z) , \(transform.columns.2.w)")
                }
                else if index == 3 {
                    //手机平移
                    infoStr.append("\n \(transform.columns.3.x) , \(transform.columns.3.y) , \(transform.columns.3.z) , \(transform.columns.3.w) \n")
                }
            }
            
            addARNavigation(transform: transform)
            var eulerAngles = currentFrame.camera.eulerAngles
            infoStr.append("相机的方向定义为欧拉角: \n")
            infoStr.append("\(eulerAngles.x) , \(eulerAngles.y) ,\(eulerAngles.z) \n")
            
            vetecorLabel.text = infoStr
            
        }
    }
    
    
    /// 手机到墙壁的距离
    private func phoneToWallDistance() -> CGFloat {
        var distance: CGFloat
        distance = 0.0
        let centerPoint = CGPoint(x: 0.5, y: 0.5)
        self.sceneView.session.currentFrame?.camera.viewMatrix(for: .portraitUpsideDown)
        
        if let result = self.sceneView.session.currentFrame?.hitTest(centerPoint, types: .featurePoint).first {
             distance = result.distance
        }
        
//        if let result = self.sceneView.hitTest(centerPoint, types: .featurePoint).first {
//             distance = result.distance
//        }
        return distance
    }
    
    
    /// MARK: 添加导航节点
    private func addARNavigation(transform: matrix_float4x4) {
        
//        向右走
        let navigationRightGeometry = SCNBox(width: 4.0, height: 0.01, length: 0.1, chamferRadius: 0.0)
        
        let materialRight = SCNMaterial()
        let imageRight = UIImage(named: "navigation_right.png")
        materialRight.diffuse.contents = imageRight
        materialRight.lightingModel = .physicallyBased
        navigationRightGeometry.materials = [materialRight]
        
        let navigationRightNode = SCNNode(geometry: navigationRightGeometry)
        
        navigationRightNode.position = SCNVector3Make(2.0, -1.3, 1)
        
        
        sceneView.scene.rootNode.addChildNode(navigationRightNode)
        
//        向上走
        let navigationUpGeometry = SCNBox(width: 0.1, height: 0.01, length: 4.0, chamferRadius: 0.0)
        let materialUp = SCNMaterial()
        let imageUp = UIImage(named: "navigation_up.png")
        materialUp.diffuse.contents = imageUp
        materialUp.lightingModel = .physicallyBased
        navigationUpGeometry.materials = [materialUp]
        
        let navigationUpNode = SCNNode(geometry: navigationUpGeometry)
        
        navigationUpNode.position = SCNVector3Make(4.0, -1.3, -1.5)
        
        sceneView.scene.rootNode.addChildNode(navigationUpNode)
        
//        向左走
        let navigationLeftGeometry = SCNBox(width: 2.0, height: 0.01, length: 0.1, chamferRadius: 0.0)
        let materialLeft = SCNMaterial()
        let imageLeft = UIImage(named: "navigation_left")
        materialLeft.diffuse.contents = imageLeft
        materialLeft.lightingModel = .physicallyBased
        navigationLeftGeometry.materials = [materialLeft]
        
        let navigationLeftNode = SCNNode(geometry: navigationLeftGeometry)
        
        navigationLeftNode.position = SCNVector3Make(3.0, -1.3, -4.0)
        
        
        sceneView.scene.rootNode.addChildNode(navigationLeftNode)
        
        
        
    }

    
    

}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    //    MARK:请求代理 新建一个ScenKit节点，与 anchor相对应
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        print("renderer-nodeFor")
        return nil
    }
    //    MARK: 通知代理。一个与新的anchor相对应的scnnode节点已经添加到当前场景中
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("renderer-didAdd")
        //        guard let anchor = anchor as? ARPlaneAnchor else {
        //            return
        //        }
        
        // 检测到新平面时创建 SceneKit 平面以实现 3D 视觉化
        //        let plane = Plane(withAnchor: anchor)
        //        planes[anchor.identifier] = plane
        //        node.addChildNode(plane)
        
        
        
    }
    
    //    MARK: 通知代理 SceneKit中的scnnode将被更新，以匹配相对应的anchor当前的状态
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        print("renderer-willUpdate")
        
    }
    //    MARK: 通知代理 ScenKit中的SCNNode已被更新，以匹配相对应的anchor当前状态
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        print("renderer-didUpdate")
        //        // 查看此平面当前是否正在渲染
        //        guard let plane = planes[anchor.identifier] else {
        //            return
        //        }
        //
        //        // anchor 更新后也需要更新 3D 几何体。例如平面检测的高度和宽度可能会改变，所以需要更新 SceneKit 几何体以匹配
        //        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    /// 通知代理 已经将一个与被删除的anchor相对应的scnnode节点从场景中删除
    ///
    /// - Parameters:
    ///   - renderer: f
    ///   - node: f
    ///   - anchor: f
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //        planes.removeValue(forKey: anchor.identifier)
    }
    
    
    
    //    MARK: 相机状态变化
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        //判断状态
        switch camera.trackingState{
        case .notAvailable:
            tipLabel.text = "跟踪不可用 "
        case .limited(ARCamera.TrackingState.Reason.initializing):
            let title = "有限的跟踪 ，原因是："
            let desc = "正在初始化，请稍后"
            tipLabel.text = title + desc
        case .limited(ARCamera.TrackingState.Reason.relocalizing):
            tipLabel.text = "有限的跟踪，原因是：重新初始化"
        case .limited(ARCamera.TrackingState.Reason.excessiveMotion):
            tipLabel.text = "有限的跟踪，原因是：设备移动过快请注意"
        case .limited(ARCamera.TrackingState.Reason.insufficientFeatures):
            tipLabel.text = "有限的跟踪，原因是：提取不到足够的特征点，请移动设备"
        case .normal:
            tipLabel.text = "跟踪正常"
            
        }
        
        
        
    }
    
    
    //    MARK: 会话被中断
    func sessionWasInterrupted(_ session: ARSession) {
        tipLabel.text = "会话中断"
    }
    
    
    //    MARK: 会话中断结束
    func sessionInterruptionEnded(_ session: ARSession) {
        tipLabel.text = "会话中断结束，已重置会话"
        sceneView.session.run(self.sessionConfig, options: .resetTracking)
    }
    
    //    MARK: 会话失败
    func session(_ session: ARSession, didFailWithError error: Error) {
        tipLabel.text = error.localizedDescription
    }
}


// MARK: - ARSessionDelegate

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        print("session-didUpdate")
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("session-didAdd")
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        print("session-didUpdate")
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        print("session-didRemove")
    }
    
}

