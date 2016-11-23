//
//  UIViewPosition.swift
//  BlogAnimatedArrow
//
//  Created by stephenw on 2016/11/23.
//  Copyright © 2016年 stephenw. All rights reserved.
//

import UIKit

extension UIView {
  
  var top:CGFloat {
    get {
      return self.frame.origin.y
    }
    set {
      var rect = self.frame
      rect.origin.y = newValue
      self.frame = rect
    }
  }
  
  var left:CGFloat {
    get {
      return self.frame.origin.x
    }
    set {
      var rect = self.frame
      rect.origin.x = newValue
      self.frame = rect
    }
  }
  
  var right:CGFloat {
    get {
      return self.frame.origin.x + self.frame.size.width
    }
    set {
      var rect = self.frame
      rect.origin.x = newValue - self.frame.size.width
      self.frame = rect
    }
  }
  
  var bottom:CGFloat {
    get {
      return self.frame.origin.y + self.frame.size.height
    }
    set {
      var rect = self.frame
      rect.origin.y = newValue - self.frame.size.height
      self.frame = rect
    }
  }
  
  var width:CGFloat {
    get {
      return self.frame.size.width
    }
    set {
      var rect = self.frame
      rect.size.width = newValue
      self.frame = rect
    }
  }
  
  var height:CGFloat {
    get {
      return self.frame.size.height
    }
    set {
      var rect = self.frame
      rect.size.height = newValue
      self.frame = rect
    }
  }
  
}
