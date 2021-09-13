import UIKit
public typealias AnimationCompletion = (() -> Void)?
extension CALayer {
  func strokeAnimation(duration: Double, from: CGFloat, to: CGFloat) {
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = from
    animation.toValue = to
    animation.duration = duration
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    self.add(animation, forKey: "line")
  }

  func animatePosition(xPoint: CGFloat, duration: Double) {
    let animation = CABasicAnimation(keyPath: "position.x")
    animation.fromValue = self.position.x            // animate from current position ...
    animation.toValue = xPoint                         // ... to whereever the new position is
    animation.duration = duration
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    self.add(animation, forKey: nil)
  }

  func animateXPositionKeyFrames(values: [CGFloat], times: [Double], duration: Double, completion: AnimationCompletion = nil) {
    CATransaction.begin()
    let animation = CAKeyframeAnimation(keyPath: "position.x")
    animation.values = values
    animation.keyTimes = times.map { NSNumber(value: $0) }
    animation.duration = CFTimeInterval(duration)
    animation.fillMode = .forwards
    CATransaction.setCompletionBlock(completion)
    animation.isRemovedOnCompletion = false
    self.add(animation, forKey: nil)
    CATransaction.commit()

  }

}
extension CGFloat {
  var deg2rad: CGFloat {
    return self * .pi / 180
  }
}
