//
//  FullScreenPull.swift
//  BlogAnimatedArrow
//
//  Created by stephenw on 2016/11/23.
//  Copyright © 2016年 stephenw. All rights reserved.
//

import UIKit

enum PullPromotionState {
  case stopped
  case refreshTriggered
  case promotionTriggered
  case refreshing
  case promotionShowing
}

let RefreshTriggerHeight:CGFloat = 70
let PromotionTirggerHeight:CGFloat = 100
private var PULL_REFRESH_PROPERTY = 0

extension UIScrollView {
  
  var pullPromotionView:PullPromotionView? {
    get {
     return getPullPromotionView()
    }
    set {
      setPullPromotionView(view: newValue)
    }
  }
  
  var showPullPromotion:Bool {
    get {
      return self.pullPromotionView!.isHidden
    }
    set {
      self.pullPromotionView?.isHidden = !newValue
      if !self.pullPromotionView!.isObserving {
        self.addObserver(self.pullPromotionView!,
                         forKeyPath: NSStringFromSelector(#selector(getter: contentOffset)),
                         options: NSKeyValueObservingOptions.new,
                         context: nil)
      } else if self.pullPromotionView!.isObserving {
        self.removeObserver(self.pullPromotionView!, forKeyPath: NSStringFromSelector(#selector(getter: contentOffset)))
      }
    }
  }
  
  func getPullPromotionView() -> PullPromotionView? {
    let view = objc_getAssociatedObject(self, &PULL_REFRESH_PROPERTY)
    if view == nil {
      createPullPromotionView()
    }
    return objc_getAssociatedObject(self, &PULL_REFRESH_PROPERTY) as? PullPromotionView
  }
  
  func setPullPromotionView(view:PullPromotionView?) {
    self.willChangeValue(forKey: NSStringFromSelector(#selector(getter: pullPromotionView)))
    objc_setAssociatedObject(self, &PULL_REFRESH_PROPERTY, view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    self.didChangeValue(forKey: NSStringFromSelector(#selector(getter: pullPromotionView)))
  }
  
  func createPullPromotionView() {
    let view = PullPromotionView()
    self.addSubview(view)
    view.scrollView = self
    view.layer.zPosition = 1
    setPullPromotionView(view: view)
  }
  
}

typealias CallBack = () -> Void

class PullPromotionView: UIView {

  weak var scrollView:UIScrollView?
  
  var refreshAction:CallBack?
  var promotionAction:CallBack?
  
  var hud = RefreshControl()
  var isObserving:Bool = false
  var _state:PullPromotionState = .stopped
  var state:PullPromotionState {
    get {
      return _state
    }
    
    set {
      self.hud.state = newValue
      if _state == newValue {
        return
      }
      dispatchState(state: newValue)
    }
  }
  
  func stopAnimate() {
    self.state = .stopped
  }
  
  func startAnimate() {
    self.state = .refreshTriggered
    self.state = .refreshing
  }
  
  convenience init() {
    var rect = UIScreen.main.bounds
    rect.origin.y = -rect.size.height
    self.init(frame:rect)
    commonInit()
  }
  
  func commonInit() {
    loadImageView()
    self.addSubview(self.hud)
  }
  
  func loadImageView() {
    let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "background"))
    let foregroundImageView = UIImageView(image: #imageLiteral(resourceName: "foreground"))
    backgroundImageView.frame = self.bounds
    foregroundImageView.frame = self.bounds
    self.addSubview(backgroundImageView)
    self.addSubview(foregroundImageView)
  }
  
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "contentOffset" {
      let point = change?[NSKeyValueChangeKey.newKey] as! CGPoint
      scrollViewDidScroll(to: point)
    }
  }
  
  func scrollViewDidScroll(to contentOffset:CGPoint) {
    if self.state == .refreshing {
      return
    }
    let scrollOffsetRefreshHold = -RefreshTriggerHeight
    let scrollOffsetPromoteHold = -PromotionTirggerHeight
    if !self.scrollView!.isDragging && self.state == .refreshTriggered {
      self.state = .refreshing
    } else if !self.scrollView!.isDragging &&
      self.state == .promotionTriggered {
      self.state = .promotionShowing
    } else if contentOffset.y < scrollOffsetRefreshHold &&
      contentOffset.y > scrollOffsetPromoteHold &&
      self.scrollView!.isDragging &&
      self.state == .stopped {
      self.state = .refreshTriggered
    } else if contentOffset.y < scrollOffsetPromoteHold &&
      (self.state == .stopped || self.state == .refreshTriggered) &&
      self.scrollView!.isDragging {
      self.state = .promotionTriggered
    } else if contentOffset.y >= scrollOffsetRefreshHold && self.state != .stopped {
      self.state = .stopped
    }
  }
  
  func dispatchState(state:PullPromotionState) {
    let previousState = _state
    _state = state
    switch state {
    case .refreshing:
      setScrollViewForRefreshing()
      if previousState == .refreshTriggered {
        //do refresh action
        if self.refreshAction != nil {
          self.refreshAction!()
        }
      }
      break
    case .promotionShowing:
      setScrollViewForPromotion()
      //do show promotion action
      if self.promotionAction != nil {
        self.promotionAction!()
      }
      break
    case .stopped:
      resetScrollView()
      break
    default:
      break
    }
  }
  
  func setScrollViewForRefreshing() {
    var currentInset = self.scrollView?.contentInset
    currentInset?.top = RefreshTriggerHeight
    let offset = CGPoint(x: self.scrollView!.contentOffset.x, y: -currentInset!.top)
    animateScrollView(contentInset: currentInset!,
                      contentOffset: offset,
                      animationDuration: 0.2)
  }
  
  func setScrollViewForPromotion() {
    var currentInset = self.scrollView?.contentInset
    currentInset?.top = self.bounds.size.height
    let offset = CGPoint(x: self.scrollView!.contentOffset.x, y: -currentInset!.top)
    self.scrollView?.contentInset = currentInset!
    self.scrollView?.setContentOffset(offset, animated: true)
  }
  
  func resetScrollView() {
    var currentInset = self.scrollView?.contentInset
    currentInset?.top = 0
    let offset = CGPoint(x: self.scrollView!.contentOffset.x, y: -currentInset!.top)
    animateScrollView(contentInset: currentInset!,
                      contentOffset: offset,
                      animationDuration: 0.2)
  }
  
  func animateScrollView(contentInset:UIEdgeInsets, contentOffset:CGPoint, animationDuration:CFTimeInterval) {
    UIView.animate(withDuration: animationDuration,
                   delay: 0,
                   options: [.allowUserInteraction, .beginFromCurrentState],
                   animations: {
                    self.scrollView?.contentOffset = contentOffset
                    self.scrollView?.contentInset = contentInset
                   },
                   completion: nil)
  }
  
}

class RefreshControl: UIView {
  
  var _state:PullPromotionState = .stopped
  var state:PullPromotionState {
    get {
      return _state
    }
    set {
      _state = newValue
      dispatchState(state: newValue)
    }
  }
  
  var hintLabel = UILabel()
  
  let refreshHint = "下拉可刷新"
  let releaseHint = "释放可刷新"
  let refreshingHint = "正在刷新"
  let promotionHint = "双11会场"
  
  convenience init() {
    let rect = UIScreen.main.bounds
    self.init(frame:CGRect(x: 0, y: 0, width: rect.size.width, height: RefreshTriggerHeight))
    self.top = rect.size.height - RefreshTriggerHeight
    self.hintLabel.text = self.refreshHint
    self.hintLabel.textColor = UIColor.white
    self.hintLabel.font = UIFont.systemFont(ofSize: 12)
    self.addSubview(self.hintLabel)
  }
  
  func dispatchState(state:PullPromotionState) {
    switch state {
    case .promotionTriggered:
      self.hintLabel.text = self.promotionHint
      break
    case .promotionShowing:
      self.hintLabel.text = nil
      break
    case .refreshing:
      self.hintLabel.text = self.refreshingHint
      break
    case .stopped:
      self.hintLabel.text = refreshHint
      break
    case .refreshTriggered:
      self.hintLabel.text = self.releaseHint
      break;
    }
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.hintLabel.sizeToFit()
    self.hintLabel.left = (self.width - self.hintLabel.width) / 2
    self.hintLabel.bottom = RefreshTriggerHeight - 8
  }
  
}
