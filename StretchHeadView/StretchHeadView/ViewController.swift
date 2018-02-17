//
//  ViewController.swift
//  StretchHeadView
//
//  Created by Liu Chuan on 2017/3/18.
//  Copyright © 2017年 LC. All rights reserved.
//

import UIKit


/// 头部视图的高度
private let headerviewH: CGFloat = 300

/// 屏幕的宽度
private let screenW: CGFloat = UIScreen.main.bounds.width

/// 导航栏的高度
private let navigationH: CGFloat = 44

/// 状态栏的高度
private let statusH: CGFloat = 20

/// 深绿色
private let darkGreen = UIColor(hue:0.40, saturation:0.78, brightness:0.68, alpha:1.00)

/// 重用标识符
private let CellID = "CellID"


class ViewController: UIViewController {
    
    // MARK: - 控件属性
    @IBOutlet weak var tableView: UITableView!
    
    /// 头部视图
    var Headerview: UIView!
    
    /// 头部视图图片
    var HeaderImage: UIImageView!
    
    /// 分割线
    var lineView: UIView!

    // MARK: - 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
        configHeaderView()
    }
    
    // MARK: - 视图即将出现时, 调用
    override func viewWillAppear(_ animated: Bool) {
        
        // 隐藏导航栏, 带动画
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // iOS7以后, 导航控制器中ScrollView\tableView顶部会添加 64 的额外高度
        // 取消自动调整滚动视图间距
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    // MARK: - 设置状态栏风格
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /// 配置TableView
    private func configTableView() {
        
        // 判断下系统版本
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }
        
        // 设置表格顶部间距, 使得HaderView不被遮挡
        tableView.contentInset = UIEdgeInsets(top: headerviewH, left: 0, bottom: 0, right: 0)
        
        // 设置指示器的间距, 等于表格顶部的间距
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.dataSource = self
        tableView.delegate = self
        
        // 注册cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID)
    }
    /// 配置HaderView
    private func configHeaderView() {
        
        Headerview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenW, height: headerviewH))
        Headerview.backgroundColor = darkGreen
        
        //HeaderImage = UIImageView(frame: CGRect(x: 0, y: 0, width: screenW, height: headerviewH))
        HeaderImage = UIImageView(frame: Headerview.bounds)
        
        /*
         UIImageView的contentMode 属性 :
         UIViewContentModeScaleToFill     会导致图片变形。根据视图的比例去拉伸图片内容。
         UIViewContentModeScaleAspectFit  保证图片比例不变，而且全部显示在ImageView中，这意味着ImageView会有部分空白。
         UIViewContentModeScaleAspectFill 保证图片比例不变，但是会填充整个ImageView，可能只有部分图片显示出来。
         UIViewContentModeCenter          保持图片原比例在视图中间显示图片内容
         
         */
        
        // 设置图像
        HeaderImage.image = UIImage(named: "Girl1")
        
        // 设置图像显示比例
        HeaderImage.contentMode = .scaleAspectFill
        
        // 设置图像裁切
        HeaderImage.clipsToBounds = true
        
        
        // 添加分割线: 1个像素点
        // 1个像素点 / 分辨率
        let lineH = 1 / UIScreen.main.scale
        
        lineView = UIView(frame: CGRect(x: 0, y: headerviewH - lineH, width: screenW, height: lineH))
        lineView.backgroundColor = UIColor.lightGray
        
        // 添加控件
        Headerview.addSubview(lineView)
        Headerview.addSubview(HeaderImage)
        view.addSubview(Headerview)
    }
}


// MARK: - 遵守 UITableViewDataSource 协议
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}



// MARK: - 遵守 UITableViewDelegate 协议
extension ViewController: UITableViewDelegate {
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
/*
         contentOffset: 即偏移量,contentOffset.y = 内容的顶部和frame顶部的差值,contentOffset.x = 内容的左边和frame左边的差值.
         contentInset:  即内边距,contentInset = 在内容周围增加的间距(粘着内容),contentInset的单位是UIEdgeInsets
*/
        // 偏移量: -200 + 顶部边距: 200, 等于0
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        //print(offsetY)
        
        // 放大图像
        guard offsetY <= 0 else {
            
            // MARK: 整体移动
            Headerview.frame.size.height = headerviewH
            Headerview.frame.origin.y = -offsetY
            
            /// HeaderView最小的Y值
            let headerViewMinY = headerviewH - navigationH - statusH  // 显示导航栏
            //let headerViewMinY = headerviewH - statusH              // 显示状态栏
            
            // min函数: 取最小值
            Headerview.frame.origin.y = -min(headerViewMinY, offsetY)
            
            // 设置透明度
            // 根据输出, 得知当 offsetY / headerViewMinY == 1时,不可见图像
            //print(offsetY / headerViewMinY)
            let progress = 1 - (offsetY / headerViewMinY)
            HeaderImage.alpha = progress
            return
        }
        
        // MARK: 放大图像
        // 调整HeaderView\ HeaderImage
        Headerview.frame.origin.y = 0
        
        // 增大 Headerview 高度
        Headerview.frame.size.height = headerviewH - offsetY
        Headerview.alpha = 1

        // 设置分割线的位置
        lineView.frame.origin.y = Headerview.frame.size.height - lineView.frame.size.height
        
        // 图像视图高度 = headView高度
        HeaderImage.frame.size.height = Headerview.frame.size.height
    }
}
