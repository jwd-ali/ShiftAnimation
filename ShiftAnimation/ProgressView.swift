//
//  ProgressView.swift
//  ShiftAnimation
//
//  Created by Jawad Ali on 12/09/2021.
//

import Foundation
import UIKit

@IBDesignable public final class ProgressView: UIView {

  private enum Constants {
    static let endAngel = CGFloat(0).deg2rad
    static let startAngel = CGFloat(180).deg2rad
  }

  //MARK:- Properties
  public var colorDotA: UIColor = .white {
    didSet {
      setNeedsDisplay()
    }
  }

  public var colorDotB: UIColor = #colorLiteral(red: 0.8536884189, green: 0.7511505485, blue: 0.04101474583, alpha: 1) {
    didSet {
      setNeedsDisplay()
    }
  }

  public var strokeWidth: CGFloat = 20 {
    didSet {
      setNeedsDisplay()
    }
  }

  public var speed: Double = 0.5


  private lazy var maximumRadius =  min(createFrames().frameB.maxX, createFrames().frameB.maxY)/2 - (strokeWidth / 2.0)
  private lazy var centre = CGPoint(x: createFrames().frameB.midX, y: createFrames().frameB.midY)

  //MARK:- Views
  private lazy var shapeLayerA: CAShapeLayer = {
    let circularLayer = CAShapeLayer()
    circularLayer.fillColor = UIColor.clear.cgColor
    circularLayer.strokeColor = colorDotA.cgColor
    circularLayer.lineWidth = strokeWidth
    circularLayer.lineCap = .round
    return circularLayer
  }()

  private lazy var shapeLayerB: CAShapeLayer = {
    let circularLayer = CAShapeLayer()
    circularLayer.fillColor = UIColor.clear.cgColor
    circularLayer.strokeColor = colorDotB.cgColor
    circularLayer.lineWidth = strokeWidth
    circularLayer.lineCap = .round
    return circularLayer
  }()

  //MARK:- Initializers

  convenience public init (with color: UIColor) {
    self.init(frame:.zero)
    self.colorDotA = color
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    controlDidLoad()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    controlDidLoad()
  }

  //MARK: View Life cycle

  private func controlDidLoad(){

    layer.addSublayer(shapeLayerA)
    layer.addSublayer(shapeLayerB)
    shapeLayerA.strokeEnd = 0.01
    shapeLayerB.strokeEnd = 0.01
  }

  public override func layoutSubviews() {
    updatePath()
  }

  private func updatePath() {
    setShapesPath()
  }

  private var isStopAnimation: Bool = false


  private func createFrames() -> (frameA: CGRect, frameB: CGRect, frameC: CGRect) {
    let dividedX = bounds.maxX/3

    let frameA = CGRect(x: 0, y: bounds.minY, width: dividedX/2, height: bounds.maxY)
    let frameB = CGRect(x: dividedX/2, y: bounds.minY, width: dividedX, height: bounds.maxY)
    let frameC = CGRect(x: dividedX * 1.5 , y: bounds.minY, width: dividedX, height: bounds.maxY)

    return (frameA, frameB, frameC)
  }

  private func setShapesPath() {

    shapeLayerA.frame = createFrames().frameB
    shapeLayerB.frame = createFrames().frameC

    self.shapeLayerA.removeAllAnimations()
    self.shapeLayerB.removeAllAnimations()

    shapeLayerA.path = UIBezierPath(arcCenter: centre, radius: maximumRadius, startAngle: Constants.startAngel, endAngle: Constants.endAngel, clockwise: true).cgPath
    shapeLayerB.path = UIBezierPath(arcCenter: centre, radius: maximumRadius, startAngle: Constants.startAngel, endAngle: Constants.endAngel, clockwise: true).cgPath
  }

  func ApplyAnimation() {

    setShapesPath()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.stepA {
        self.stepB {
          if !self.isStopAnimation { self.ApplyAnimation() }
        }
      }
    }
  }

  private func stepA(completion: AnimationCompletion) {
    shapeLayerA.strokeAnimation(duration: speed, from: 0.01, to: 1)
    shapeLayerA.animatePosition(xPoint: createFrames().frameA.midX, duration: speed)
    shapeLayerB.animateXPositionKeyFrames(values: [shapeLayerB.frame.midX, createFrames().frameC.minX, createFrames().frameC.maxX], times: [0, 0.8, 1], duration: speed, completion: completion)
  }

  func stepB(completion: AnimationCompletion) {
    shapeLayerA.path = UIBezierPath(arcCenter: centre, radius: maximumRadius, startAngle: Constants.endAngel, endAngle: Constants.startAngel, clockwise: false).cgPath
    shapeLayerA.strokeAnimation(duration: speed, from: 1, to: 0.01)
    shapeLayerA.animateXPositionKeyFrames(values: [shapeLayerA.frame.minX, -createFrames().frameA.midX - createFrames().frameA.midX/3], times: [0,1], duration: speed)
    shapeLayerB.animateXPositionKeyFrames(values: [shapeLayerB.frame.maxX, createFrames().frameC.midX], times: [0,1], duration: speed, completion: completion)
  }

  private func stopAnimation() {
    isStopAnimation.toggle()
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    isStopAnimation.toggle()
    ApplyAnimation()
  }
}
