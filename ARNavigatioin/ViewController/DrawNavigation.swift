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
    var vectorNavArray = Array<SCNVector3>()//向量导航
    
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
    
    /// 展示导航
    ///
    /// - Parameter vectorArray:
    public func showNavigation(vectorArray: Array<SCNVector3>) {
            
        for model in vectorArray {
            self.vectorNavArray.append(model)
        }
        
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
        
        var depth = 0.0 //Y轴上的偏移(高度)
        var tanPre:Float = 0.0//上一个节点的角度
        
        for navModel in self.vectorNavArray {//循环取出向量导航数据，来加载世界导航节点
            
            var moveAngle: Float = 0.0//子节点相对于父节点旋转的角度
            
            let rotateNode = SCNNode(geometry: rotateGeometry)//每个向量的父节点,用于旋转方向
            
            var wRice:Float = 0.0//X周上的长度
            
            if navLastNodeArray.count > 0 {
                
                depth = 0.0
                
                let previousNavNode = navLastNodeArray.last //获取到上一个节点，将下一个向量的根节点（旋转节点）添加到该节点中
                
                rotateNode.position = SCNVector3Make((previousNavNode?.position.x)!/2, 0.0, 0.0)
                
                previousNavNode?.addChildNode(rotateNode)
                
                wRice = sqrt(pow((navModel.x - (previousNavNode?.position.x)!),2.0) + pow((navModel.z - (previousNavNode?.position.z)!), 2.0))
                
            }
            else{
                depth = 1.0
                rotateNode.position = SCNVector3Make(0.0, 0.0, 0.0)
                wRice = sqrt(pow(navModel.x,2.0) + pow(navModel.z, 2.0))
                self.scenView.scene.rootNode.addChildNode(rotateNode)
                
            }
            
            //计算偏转的角度
            var tanCurrent:Float = 0.0
            if navLastNodeArray.count > 0 {
                let previousNavNode = navLastNodeArray.last //获取到上一个节点，将下一个向量的根节点（旋转节点）添加到该节点中
                
                let z = navModel.z - (previousNavNode?.position.z)!
                let x = navModel.x - (previousNavNode?.position.x)!
                tanCurrent = z / x
                if previousNavNode!.position.z > 0.0 && previousNavNode!.position.x > 0.0 {//第二象限
                    
                    if x > 0 {
                        moveAngle = 90 * (tanPre - tanCurrent)
                    }
                    
                    else if x < 0{
                        if z < 0 {
                            moveAngle = 90 + tanPre*90
                        }
                        else if z > 0 {
                            moveAngle = 90*(tanPre + fabs(tanCurrent)) - 180
                        }
                        else if z == 0 {
                            moveAngle = 90 * tanPre - 180
                        }
                    }
                    else {
                        if z > 0 {
                            moveAngle = 90 * tanPre - 90
                        }
                        else if z < 0 {
                            moveAngle = 90 * tanPre + 90
                        }
                    }
                    
                }
                
                
            }
            else {
                tanCurrent = fabs(navModel.z) / fabs(navModel.x)
            }
            
            
            print("tanPre \(tanPre)  tanCurrent \(tanCurrent) ")
            if tanPre > tanCurrent {
                moveAngle = 90 * (tanPre - tanCurrent)
            }
            else {
                moveAngle = 90 * (tanPre - tanCurrent)
            }
            
            tanPre = tanCurrent
            
            let navigationGeometry = SCNBox(width: CGFloat(wRice), height: 0.001, length: 0.2, chamferRadius: 0.0)
            navigationGeometry.materials = [navMaterial]
            let navigationNode = SCNNode(geometry: navigationGeometry)
            navigationNode.position = SCNVector3Make(wRice/2.0, Float(-depth), 0.0)
            
            rotateNode.addChildNode(navigationNode)
            rotateNode.eulerAngles.y = moveAngle / 180 * .pi //旋转跟节点来指明方向
            
            print("navNode \(navigationNode.position)  moveAngle \(moveAngle)")
            
            self.navLastNodeArray.append(navigationNode)
            
            
        }
    }
    
    
}
