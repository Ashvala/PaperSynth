// Copyright © 2023 Brad Howes. All rights reserved.
#if os(iOS)

import UIKit

/**
 Custom UIControl/NSControl that depicts a value as a point on a circle. Changing the value is done by touching on the
 control and moving up to increase and down to decrease the current value. While touching, moving away from the control
 in either direction will increase the resolution of the touch changes, causing the value to change more slowly as
 vertical distance changes. Pretty much works like UISlider but with the travel path as an arc.
 Visual representation of the knob is done via CoreAnimation components, namely CAShapeLayer and UIBezierPath. The
 diameter of the arc of the knob is defined by the min(width, height) of the view's frame. The start and end of the arc
 is controlled by the `startAngle` and `endAngle` settings.
 */
open class Knob: UIControl {

  fileprivate class LayerDelegate: NSObject, CALayerDelegate {
    private let null = NSNull()
    private weak var knob: Knob?
    
    init(_ knob: Knob) {
      self.knob = knob
      super.init()
    }

    public func display(_ layer: CALayer) { knob?.drawLayer(layer) }
    public func action(for layer: CALayer, forKey event: String) -> CAAction? { null }
  }

  /// The minimum value reported by the control.
  public var minimumValue: Float = 0.0 {
    didSet {
      if minimumValue > maximumValue { maximumValue = minimumValue + 1.0 }
      setValue(_normalizedValue * (maximumValue - oldValue) + oldValue, animated: false)
    }
  }

  /// The maximum value reported by the control.
  public var maximumValue: Float = 1.0 {
    didSet {
      if maximumValue < minimumValue { minimumValue = maximumValue - 1.0 }
      setValue(_normalizedValue * (oldValue - minimumValue) + minimumValue, animated: false)
    }
  }

  /// The current value of the control, expressed in a value between `minimumValue` and `maximumValue`
  @objc public dynamic var value: Float {
    get { _normalizedValue * (maximumValue - minimumValue) + minimumValue }
    set { setValue(newValue, animated: false) }
  }

  /// The distance in pixels used for calculating mouse/touch changes to the knob value. By default, use the smaller of
  /// the view's width and height.
  open var travelDistance: CGFloat { (min(bounds.height, bounds.width)) }

  /// How much travel is need to change the knob from `minimumValue` to `maximumValue`.
  /// By default this is 1x the `travelDistance` value. Setting it to 2 will require 2x the `travelDistance` to go from
  /// `minimumValue` to `maximumValue`.
  public var touchSensitivity: CGFloat = 1.0

  /// Percentage of `travelDistance` where a touch/mouse event will perform maximum value change. This defines a
  /// vertical region in the middle of the view. Events outside of this region will have finer sensitivity and control
  /// over value changes.
  public var maxChangeRegionWidthPercentage: CGFloat = 0.1

  /// Controls the width of the track arc that is shown behind the progress track. The track with will be the smaller of
  /// the width/height of the bounds times this value.
  public var trackWidthFactor: CGFloat = 0.08 { didSet { trackLayer.setNeedsDisplay() } }

  /// The color of the arc shown after the current value.
  public var trackColor: UIColor = .darkGray { didSet { trackLayer.setNeedsDisplay() } }

  /// Controls the width of the progress arc that is shown on top of the track arc. The width with will be the smaller
  /// of the width/height of the bounds times this value. See `trackWidthFactor`.
  public var progressWidthFactor: CGFloat = 0.055 { didSet { progressLayer.setNeedsDisplay() } }

  /// The color of the arc from the start up to the current value.
  public var progressColor: UIColor = .init(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { progressLayer.setNeedsDisplay() } }

  /// The width of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorWidthFactor: CGFloat = 0.055 { didSet { indicatorLayer.setNeedsDisplay() } }

  /// The color of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorColor: UIColor = .init(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { indicatorLayer.setNeedsDisplay() } }

  /// The proportion of the radial line drawn from the current value on the arc towards the arc center.
  /// Range is from 0.0 to 1.0, where 1.0 will draw a complete line, and anything less will draw that fraction of it
  /// starting from the arc.
  public var indicatorLineLength: CGFloat = 0.3 { didSet { indicatorLayer.setNeedsDisplay() } }

  /// Number of ticks to show inside the track, with the first indicating the `minimumValue` and the last indicating
  /// the `maximumValue`
  public var tickCount: Int = 0 { didSet { ticksLayer.setNeedsDisplay() } }

  /// Offset for the start of a tick line. Range is from 0.0 to 1.0 where 0.0 starts at the circumference of the arc,
  /// and 0.5 is midway between the circumference and the center along a radial.
  public var tickLineOffset: CGFloat = 0.1 { didSet { ticksLayer.setNeedsDisplay() } }

  /// Length of the tick. Range is from 0.0 to 1.0 where 1.0 will draw a line ending at the center of the knob.
  public var tickLineLength: CGFloat = 0.2 { didSet { ticksLayer.setNeedsDisplay() } }

  /// The width of the tick line.
  public var tickLineWidth: CGFloat = 1.0 { didSet { ticksLayer.setNeedsDisplay() } }

  /// The color of the tick line.
  public var tickColor: UIColor = .black { didSet { ticksLayer.setNeedsDisplay() } }

  /// The text element to use to show the knob's value and name.
  public var valueLabel: UILabel?

  /// The name to show when the knob is not being manipulated. If nil, the knob's value is always shown.
  public var valueName: String?

  /// The formatter to use to generate a textual representation of the knob's current value. If nil, use Swift's default
  /// formatting for floating-point numbers.
  public var valueFormatter: NumberFormatter?

  /// Time to show the last value once manipulation has ceased, before the name is shown.
  public var valuePersistence: TimeInterval = 1.0

  /// Duration of the animation used when transitioning from the value to the name in the label. Value of 0.0 implies no
  /// animation.
  public var nameTransitionDuration = 0.5

  /// Obtain a formatted value of the knob's current value.
  public var formattedValue: String { valueFormatter?.string(from: .init(value: value)) ?? "\(value)" }

  /// Obtain the manipulating state of the knob. This is `true` during a touch event or a mouse-down event, and it goes
  /// back to `false` once the event ends.
  public private(set) var manipulating = false

  /**
   The starting angle of the arc where a value of 0.0 is located. Arc angles are explained in the UIBezier
   documentation for init(arcCenter:radius:startAngle:endAngle:clockwise:). In short, a value of 0.0 will start on
   the positive X axis, a positive PI/2 will lie on the negative Y axis. The default values will leave a 90° gap at
   the bottom.
   */
  public var startAngle: CGFloat = -.pi / 180.0 * 225.0 {
    didSet {
      trackLayer.setNeedsDisplay()
      progressLayer.setNeedsDisplay()
      indicatorLayer.setNeedsDisplay()
      ticksLayer.setNeedsDisplay()
    }
  }

  /// The ending angle of the arc where a value of 1.0 is located. See `startAngle` for additional info.
  public var endAngle: CGFloat = .pi / 180.0 * 45.0 {
    didSet {
      trackLayer.setNeedsDisplay()
      progressLayer.setNeedsDisplay()
      indicatorLayer.setNeedsDisplay()
      ticksLayer.setNeedsDisplay()
    }
  }

  public override class var layerClass: Swift.AnyClass { CAShapeLayer.self }

  private let trackLayer = CAShapeLayer()
  private let progressLayer = CAShapeLayer()
  private let indicatorLayer = CAShapeLayer()
  private let ticksLayer = CAShapeLayer()
  private let updateQueue = DispatchQueue(label: "KnobUpdates", qos: .userInteractive, attributes: [],
                                          autoreleaseFrequency: .inherit, target: .main)

  private var _normalizedValue: Float = 0.0
  private var panOrigin: CGPoint = .zero
  private var restorationTimer: Timer?

  private var expanse: CGFloat { min(bounds.width, bounds.height) }
  private var radius: CGFloat { expanse / 2 - trackLineWidth }
  private var angleForNormalizedValue: CGFloat { angle(for: _normalizedValue) }

  private var trackLineWidth: CGFloat { expanse * trackWidthFactor }
  private var progressLineWidth: CGFloat { expanse * progressWidthFactor }
  private var indicatorLineWidth: CGFloat { expanse * indicatorWidthFactor }

  private lazy var layerDelegate: LayerDelegate = .init(self)

  private func angle(for normalizedValue: Float) -> CGFloat {
    .init(normalizedValue) * (endAngle - startAngle) + startAngle
  }

  private func clampedValue(_ value: Float) -> Float { min(maximumValue, max(minimumValue, value)) }
  private func normalizedValue(_ value: Float) -> Float { (value - minimumValue) / (maximumValue - minimumValue) }

  /**
   Construction from an encoded representation.
   - parameter aDecoder: the representation to use
   */
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  /**
   Construct a new instance with the given location and size. A knob will take the size of the smaller of width and
   height dimensions given in the `frame` parameter.
   - parameter frame: geometry of the new knob
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
}

// MARK: - Setting Value
extension Knob {

  /**
   Set the value of the knob.
   - parameter value: the new value to use
   - parameter animated: true if animating the change to the new value
   */
  public func setValue(_ value: Float, animated: Bool = false) {
    _normalizedValue = normalizedValue(clampedValue(value))
    restorationTimer?.invalidate()
    valueLabel?.text = formattedValue
    progressLayer.setNeedsDisplay()
    indicatorLayer.setNeedsDisplay()
  }
}

extension Knob {

  /**
   Reposition layers to reflect new size.
   */
  public override func layoutSubviews() {
    super.layoutSubviews()
    let layerBounds = bounds.offsetBy(dx: -bounds.midX, dy: -bounds.midY)
    let layerCenter = CGPoint(x: bounds.midX, y: bounds.midY)
    for layer in [trackLayer, progressLayer, indicatorLayer, ticksLayer] {
      layer.bounds = layerBounds
      layer.position = layerCenter
      layer.setNeedsDisplay() // display(layer)
    }
  }

  fileprivate func drawLayer(_ layer: CALayer) {
    if layer === trackLayer {
      trackLayer.lineWidth = trackLineWidth
      trackLayer.strokeColor = trackColor.cgColor
      trackLayer.path = createRing().cgPath
    } else if layer === progressLayer {
      progressLayer.lineWidth = progressLineWidth
      progressLayer.strokeColor = progressColor.cgColor
      progressLayer.path = createRing().cgPath
      progressLayer.strokeEnd = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
    } else if layer === ticksLayer {
      ticksLayer.lineWidth = tickLineWidth
      ticksLayer.strokeColor = tickColor.cgColor
      createTicks()
    } else if layer === indicatorLayer {
      indicatorLayer.lineWidth = indicatorLineWidth
      indicatorLayer.strokeColor = indicatorColor.cgColor
      createIndicator()
    }
  }
}

// MARK: - Label updating
extension Knob {

  public func restoreLabelWithName() {
    notifyTarget()
    restorationTimer?.invalidate()
    guard
      let valueLabel = self.valueLabel,
      let valueName = self.valueName
    else { return }

    restorationTimer = Timer.scheduledTimer(withTimeInterval: valuePersistence, repeats: false) { [weak self] _ in
      guard let self = self else { return }
      self.performRestoration(label: valueLabel, value: valueName)
    }
  }

  private func performRestoration(label: UILabel, value: String) {
      UIView.transition(with: label, duration: nameTransitionDuration,
                        options: [.curveLinear, .transitionCrossDissolve]) {
        label.text = value
      } completion: { _ in
        label.text = value
      }
  }
}

// MARK: - Event Tracking
extension Knob {

  override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    panOrigin = touch.location(in: self)
    manipulating = true
    notifyTarget()
    return true
  }

  override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    updateValue(with: touch.location(in: self))
    return true
  }

  override open func cancelTracking(with event: UIEvent?) {
    manipulating = false
    super.cancelTracking(with: event)
    restoreLabelWithName()
  }

  override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    manipulating = false
    super.endTracking(touch, with: event)
    restoreLabelWithName()
  }
}

// MARK: - Private
extension Knob {

  private var maxChangeRegionWidthHalf: CGFloat { min(4, travelDistance * maxChangeRegionWidthPercentage) / 2 }
  private var halfTravelDistance: CGFloat { travelDistance / 2 }

  private func updateValue(with point: CGPoint) {
    defer { panOrigin = CGPoint(x: panOrigin.x, y: point.y) }

    // dX should never be equal to or greater than minDimensionHalf
    let dX = min(abs(bounds.midX - point.x), halfTravelDistance - 1)
    let dY = panOrigin.y - point.y

    // Scale Y changes by how far away in the X direction the touch is -- farther away the more one must travel in Y
    // to achieve the same change in value. Use `touchSensitivity` to increase/reduce this effect.
    //
    // - if the touch/mouse is <= maxChangeRegionWidthHalf pixels from the center X then scaleT is 1.0
    // - otherwise, it linearly gets smaller as X moves away from the center
    //
    let scaleT = dX <= maxChangeRegionWidthHalf ? 1.0 : (1.0 - dX / halfTravelDistance)
    print(dX, scaleT)

    let deltaT = Float((dY * scaleT) / (travelDistance * touchSensitivity))
    let change = deltaT * (maximumValue - minimumValue)
    self.value += change
    notifyTarget()
  }

  private func notifyTarget() {
    updateQueue.async { self.sendActions(for: .valueChanged) }
  }
}

extension Knob {

  private func initialize() {
    setContentHuggingPriority(.defaultHigh, for: .horizontal)
    setContentHuggingPriority(.defaultHigh, for: .vertical)

    setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    setContentCompressionResistancePriority(.defaultLow, for: .vertical)

    for layer in [trackLayer, ticksLayer, progressLayer, indicatorLayer] {
      self.layer.addSublayer(layer)
      layer.needsDisplayOnBoundsChange = true
      layer.delegate = layerDelegate
      layer.fillColor = UIColor.clear.cgColor
      layer.backgroundColor = UIColor.clear.cgColor
      layer.allowsEdgeAntialiasing = true
//      layer.lineCap = .round
      layer.strokeStart = 0.0
    }

    trackLayer.strokeEnd = 1.0
    progressLayer.strokeEnd = 0.0
    indicatorLayer.strokeEnd = 1.0
  }

  private func createRing() -> UIBezierPath {
    .init(arcCenter: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
  }

  private func createIndicator() {
    let indicator = UIBezierPath()
    indicator.move(to: CGPoint(x: radius, y: 0.0))
    indicator.addLine(to: CGPoint(x: radius * (1.0 - indicatorLineLength), y: 0.0))
    indicator.apply(.init(rotationAngle: angleForNormalizedValue))
    indicatorLayer.path = indicator.cgPath
  }

  private func createTicks() {
    let ticks = UIBezierPath()
    for tickIndex in 0..<tickCount {
      let tick = UIBezierPath()
      let theta = angle(for: Float(tickIndex) / max(1.0, Float(tickCount - 1)))
      tick.move(to: CGPoint(x: 0.0 + radius * (1.0 - tickLineOffset), y: 0.0))
      tick.addLine(to: CGPoint(x: 0.0 + radius * (1.0 - tickLineLength), y: 0.0))
      tick.apply(CGAffineTransform(rotationAngle: theta))
      ticks.append(tick)
    }
    ticksLayer.path = ticks.cgPath
  }
}

#endif
