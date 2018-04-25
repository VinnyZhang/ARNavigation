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

class ViewController: UIViewController ,ARSCNViewDelegate{
    
    var sceneView: ARSCNView! //场景
    var planes = [UUID:Plane]() //字典，存储场景中当前渲染的所有平面
    var sessionConfig: ARConfiguration!//会话配置
    var tipLabel = UILabel() //提示标签
    var vetecorLabel = UILabel() //位置信息
    var countSession: Int = 0
    
    //    MARK: - viewcontroller的生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        
        setupMySubView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK: - ARSCNViewDelegate
    //    MARK:请求代理 新建一个ScenKit节点，与 anchor相对应
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//
//    }
    //    MARK: 通知代理。一个与新的anchor相对应的scnnode节点已经添加到当前场景中
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }

        // 检测到新平面时创建 SceneKit 平面以实现 3D 视觉化
//        let plane = Plane(withAnchor: anchor)
//        planes[anchor.identifier] = plane
//        node.addChildNode(plane)

    }
    
    //    MARK: 通知代理 SceneKit中的scnnode将被更新，以匹配相对应的anchor当前的状态
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        
        
    }
    //    MARK: 通知代理 ScenKit中的SCNNode已被更新，以匹配相对应的anchor当前状态
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
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
        
        countSession += 1
        //判断状态
        switch camera.trackingState{
        case .notAvailable:
            tipLabel.text = "跟踪不可用 \(countSession)"
        case .limited(ARCamera.TrackingState.Reason.initializing):
            let title = "有限的跟踪 \(countSession) ，原因是："
            let desc = "正在初始化，请稍后"
            tipLabel.text = title + desc
        case .limited(ARCamera.TrackingState.Reason.relocalizing):
            tipLabel.text = "有限的跟踪，原因是：重新初始化 \(countSession)"
        case .limited(ARCamera.TrackingState.Reason.excessiveMotion):
            tipLabel.text = "有限的跟踪，原因是：设备移动过快请注意 \(countSession)"
        case .limited(ARCamera.TrackingState.Reason.insufficientFeatures):
            tipLabel.text = "有限的跟踪，原因是：提取不到足够的特征点，请移动设备 \(countSession)"
        case .normal:
            tipLabel.text = "跟踪正常 \(countSession)"
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
    
    
    //    MARK: - 触控
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sessionCurrentFrame()
    }
    
    
    //    MARK: - private
    
    private func setupMySubView() {
        self.view.addSubview(tipLabel)
        tipLabel.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 30)
        tipLabel.textColor = UIColor.blue
        
        self.view.addSubview(vetecorLabel)
        vetecorLabel.frame = CGRect(x: 0, y: tipLabel.frame.origin.y + tipLabel.frame.size.height + 5, width: self.view.frame.size.width, height: 300)
        vetecorLabel.numberOfLines = 0
        vetecorLabel.textColor = UIColor.blue
        
        
        
    }
    
    //MARK: 初始化场景
    private func setupScene() {
        sceneView = ARSCNView()
        sceneView.frame = self.view.frame
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    //    MARK: 配置会话
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
    //    MARK: 手机的方位
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
            
//            matrixChange(transform: transform,originVector: vector_float4(x: 0, y: 0, z: 0, w: 1))
//            addARNavigation(transform: transform)
            var eulerAngles = currentFrame.camera.eulerAngles
            infoStr.append("相机的方向定义为欧拉角: \n")
            infoStr.append("\(eulerAngles.x) , \(eulerAngles.y) ,\(eulerAngles.z) \n")
            
            vetecorLabel.text = infoStr
            
        }
    }
    
    private func matrixChange(transform: matrix_float4x4 ,originVector: vector_float4) -> (SCNVector3){
        let mx = transform.columns.0.x * originVector.x - transform.columns.1.y * originVector.y + transform.columns.3.x * originVector.w
        let my = transform.columns.0.y * originVector.x - transform.columns.1.y * originVector.y + transform.columns.3.y * originVector.w
        let mz = originVector.z + transform.columns.3.z * originVector.w
        let mw = originVector.w
        
        
        
        print("mx= \(mx) my= \(my) mz= \(mz) mw=\(mw)")
        
        return SCNVector3Make(mx, my, mz)
    }
    
    
    private func planeAnchor()
    {
        
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
        
        let vectionR:SCNVector3 = matrixChange(transform:transform , originVector: vector_float4(x: 2.0, y: -1.3, z: 1, w: 1))
        
//        navigationRightNode.position = SCNVector3Make(2.0, -1.3, 1)
        navigationRightNode.position = vectionR
        
        sceneView.scene.rootNode.addChildNode(navigationRightNode)
        
//        向上走
        let navigationUpGeometry = SCNBox(width: 0.1, height: 0.01, length: 4.0, chamferRadius: 0.0)
        let materialUp = SCNMaterial()
        let imageUp = UIImage(named: "navigation_up.png")
        materialUp.diffuse.contents = imageUp
        materialUp.lightingModel = .physicallyBased
        navigationUpGeometry.materials = [materialUp]
        
        let navigationUpNode = SCNNode(geometry: navigationUpGeometry)
        
        let vectionUp:SCNVector3 = matrixChange(transform:transform , originVector: vector_float4(x: 4.0, y: -1.3, z: -1.5, w: 1))
        
//        navigationUpNode.position = SCNVector3Make(4.0, -1.3, -1.5)
        navigationUpNode.position = vectionUp
        
        sceneView.scene.rootNode.addChildNode(navigationUpNode)
        
//        向左走
        let navigationLeftGeometry = SCNBox(width: 2.0, height: 0.01, length: 0.1, chamferRadius: 0.0)
        let materialLeft = SCNMaterial()
        let imageLeft = UIImage(named: "navigation_left")
        materialLeft.diffuse.contents = imageLeft
        materialLeft.lightingModel = .physicallyBased
        navigationLeftGeometry.materials = [materialLeft]
        
        let navigationLeftNode = SCNNode(geometry: navigationLeftGeometry)
        
        let vectionL:SCNVector3 = matrixChange(transform:transform , originVector: vector_float4(x: 3.0, y: -1.3, z: -4.0, w: 1))
        
//        navigationLeftNode.position = SCNVector3Make(3.0, -1.3, -4.0)
        navigationLeftNode.position = vectionL
        
        sceneView.scene.rootNode.addChildNode(navigationLeftNode)
        
        
        
    }


}

