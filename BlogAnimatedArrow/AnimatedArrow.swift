//
//  AnimatedArrow.swift
//  BlogAnimatedArrow
//
//  Created by stephenw on 2016/11/21.
//  Copyright © 2016年 stephenw. All rights reserved.
//

import UIKit

class AnimatedArrow: UIView {
  
  var circleLayer:CAShapeLayer?
  var containerLayer:CALayer?
  
  private var _progress:CGFloat = 0
  var progress:CGFloat {
    get {
      return _progress
    }
    set {
      _progress = newValue
      self.circleLayer?.strokeEnd = min(0.95, newValue)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  func startAnimation() {
    self.containerLayer?.isHidden = true
    let animation = CABasicAnimation(keyPath: "transform.rotation.z")
    animation.fromValue = 0
    animation.toValue = M_PI * 2
    animation.duration = 1
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    animation.repeatCount = Float.infinity
    self.circleLayer?.add(animation, forKey: "infinity_rotate")
  }
  
  func stopAnimation() {
    self.containerLayer?.isHidden = false
    self.circleLayer?.removeAnimation(forKey: "infinity_rotate")
  }
  
  func commonInit() {
    loadCircleLayer()
    loadArrowLayer()
  }
  
  func loadCircleLayer() {
    let layer = CAShapeLayer()

    //incase self.bounds.size is not a square
    let radius = min(self.bounds.width, self.bounds.height)
    let frame = CGRect(x: 0, y: 0, width: radius, height: radius)
    layer.frame = frame
    layer.strokeColor = UIColor.black.cgColor
    layer.fillColor = UIColor.clear.cgColor
    
    let path = UIBezierPath(ovalIn: frame)
    layer.path = path.cgPath
    layer.lineWidth = 1
    layer.lineCap = kCALineCapRound
    layer.strokeStart = 0
    layer.strokeEnd = self.progress
    
    self.layer.addSublayer(layer)
    self.circleLayer = layer
  }
  
  func loadArrowLayer() {
    self.containerLayer = CALayer()
    self.containerLayer?.frame = self.bounds
    self.containerLayer?.addSublayer(templateLayer(path: middlePath()))
    self.containerLayer?.addSublayer(templateLayer(path: leftPath()))
    self.containerLayer?.addSublayer(templateLayer(path: rightPath()))
    self.layer.addSublayer(self.containerLayer!)
  }
  
  func templateLayer(path:CGPath) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = self.bounds
    layer.strokeColor = UIColor.black.cgColor
    layer.path = path
    layer.lineWidth = 1
    layer.lineCap = kCALineCapRound
    layer.fillColor = UIColor.clear.cgColor
    return layer
  }
  
  func middlePath() -> CGPath {
    let width = self.bounds.size.width / 2;
    let path = UIBezierPath()
    path.move(to: CGPoint(x: width - 0.5, y: width / 2))
    path.addLine(to: CGPoint(x: width - 0.5, y: 3 * width / 2))
    return path.cgPath
  }
  
  func leftPath() -> CGPath {
    let width = self.bounds.size.width / 2;
    let path = UIBezierPath()
    path.move(to: CGPoint(x: width / 2, y: width))
    path.addLine(to: CGPoint(x: width - 0.5, y: 3 * width / 2))
    return path.cgPath
  }
  
  func rightPath() -> CGPath {
    let width = self.bounds.size.width / 2;
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 3 * width / 2, y: width))
    path.addLine(to: CGPoint(x: width - 0.5, y: 3 * width / 2))
    return path.cgPath
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
