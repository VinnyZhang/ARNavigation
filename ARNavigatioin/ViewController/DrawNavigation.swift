//
//  DrawNavigation.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/15.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class DrawNavigation: NSObject {
    
    var scenView: ARSCNView!//AR视图
    var downRice: Float!//向下移动的距离
    var backRice: Float!//向后移动的距离
    var navArray = Array<NavigationModel>()//导航数据数组
    var navLastNodeArray = Array<SCNNode>()//每个方向上最后添加的导航节点
    
    /// 初始化
    ///
    /// - Parameter scenView: ARSCNView
    init(_ scenView: ARSCNView) {
        super.init()
        self.scenView = scenView
    }
    
    /// 展示导航路线
    ///
    /// - Parameters:
    ///   - navArray: 导航方向标数组
    ///   - downRice: 从扫描点向下移动的距离
    ///   - backRice: 从扫描点向后移动的距离
    func showNavigation(navArray: Array<NavigationModel> ,downRice: Float ,backRice: Float) {
        
//        for node in self.scenView.scene.rootNode.childNodes {
//            node.removeFromParentNode()
//        }
        
        for model in navArray {
            self.navArray.append(model)
        }
        self.downRice = -downRice
        self.backRice = backRice
        
        /**
         Y轴：垂直方向，正方向朝上
         X轴：东西方向，正方向朝西
         Z轴：南北方向，正方向朝北
         每个方向上的导航节点添加到一个（0，0，0）的父节点上，方便之后的旋转操作
         添加节点时全部添加到X轴的正方向上，之后再根据方向进行旋转操作
        **/
        
        let rotateGeometry = SCNBox(width: 0.0, height: 0.0, length: 0.0, chamferRadius: 0.0)//旋转节点几何形状
        
        let navMaterial = SCNMaterial()//导航节点的素材
        let navImage = UIImage(named: "navigation_right")
        navMaterial.diffuse.contents = navImage
        navMaterial.lightingModel = .physicallyBased
        
        var totalAngle: Float = 0.0//旋转节点旋转的总角度
        var superNodeCenterX: Float = 0.0 //父节点中心点X轴偏移的位置
        
        for navModel in self.navArray {//循环取出方向导航数据，来加载世界导航节点
            
            var moveAngle: Float = 0.0
            
            if abs(totalAngle) > navModel.westDD {
                let tempT = abs(totalAngle) - navModel.westDD
                moveAngle = -tempT
                totalAngle = navModel.westDD
            }
            else {
                let tempT = navModel.westDD - abs(totalAngle)
                moveAngle = tempT
                totalAngle = navModel.westDD
            }
            
            let rotateNode = SCNNode(geometry: rotateGeometry)
            
            
            if navLastNodeArray.count > 0 {
                
                rotateNode.position = SCNVector3Make(superNodeCenterX, 0.0, 0.0)
                
                let navNode = navLastNodeArray.last
                navNode?.addChildNode(rotateNode)
            }
            else{
//                rotateNode.position = SCNVector3Make(0.0, self.downRice, 0.0)
                rotateNode.position = SCNVector3Make(0.0, 0.0, 0.0)
                
                self.scenView.scene.rootNode.addChildNode(rotateNode)
            }
            
            let navigationGeometry = SCNBox(width: CGFloat(navModel.wRice), height: 0.001, length: 0.2, chamferRadius: 0.0)
            navigationGeometry.materials = [navMaterial]
            let navigationNode = SCNNode(geometry: navigationGeometry)
            navigationNode.position = SCNVector3Make(navModel.wRice/2, 0.0, 0.0)
            rotateNode.addChildNode(navigationNode)
            rotateNode.eulerAngles.y = moveAngle / 180 * .pi //旋转跟节点来指明方向
            
            self.navLastNodeArray.append(navigationNode)
            
            superNodeCenterX = navModel.wRice / 2
        }
        
    }
    
    
}
