//
//  MainViewController.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/24.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let navBtn = UIButton(frame: CGRect(x: 50.0, y: 100.0, width: self.view.frame.size.width - 100.0, height: 50.0))
        self.view.addSubview(navBtn)
        navBtn.setTitle("扫图后重新确定世界坐标系，根据方向加载导航", for: .normal)
        navBtn.setTitleColor(UIColor.blue, for: .normal)
        
        navBtn.addTarget(self, action: #selector(navClick), for: .touchUpInside)
        
        let arrowBtn = UIButton(frame: CGRect(x: 50.0, y: 200.0, width: self.view.frame.size.width - 100.0, height: 50.0))
        self.view.addSubview(arrowBtn)
        arrowBtn.setTitle("箭头导航", for: .normal)
        arrowBtn.setTitleColor(UIColor.blue, for: .normal)
        
        arrowBtn.addTarget(self, action: #selector(arrowClick), for: .touchUpInside)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

     @objc func navClick() {
        let navController = ARNavigationViewController()
        self.navigationController?.pushViewController(navController, animated: true)
    }
    
    @objc func arrowClick() {
        let arrowController = ArrowViewController()
        self.navigationController?.pushViewController(arrowController, animated: true)
    }

}
