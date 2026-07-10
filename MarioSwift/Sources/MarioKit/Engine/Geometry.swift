import Foundation

public struct IPoint: Equatable, Sendable {
  public var x: Int
  public var y: Int

  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
}

/// Integer rectangle in level pixel coordinates (origin top-left).
public struct IRect: Equatable, Sendable {
  public var x: Int
  public var y: Int
  public var width: Int
  public var height: Int

  public init(x: Int, y: Int, width: Int, height: Int) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }

  public var maxX: Int { x + width }
  public var maxY: Int { y + height }

  /// Inclusive-edge containment, matching the legacy `Level.Contains`:
  /// points on the rectangle border count as inside. Collision behavior
  /// (standing exactly on top of a block) depends on this.
  public func contains(_ point: IPoint) -> Bool {
    point.x >= x && point.x <= x + width && point.y >= y && point.y <= y + height
  }
}

/// Which side of the *source* object a collision resolves to, using the
/// legacy names: `.up` means "source landed on top of dest", `.left` means
/// "dest is against the source's right side" (the source gets pushed left),
/// and so on.
public enum CollisionDirection: Equatable, Sendable {
  case right, left, up, down
  case topLeft, topRight, bottomLeft, bottomRight
}

public struct Collision: Equatable, Sendable {
  public var src: IRect
  public var dest: IRect
  public var dir: CollisionDirection
}

/// Faithful port of the legacy `Level.Intersects`: AABB overlap test with
/// inclusive edges, then direction classification by which source corners are
/// inside the destination, comparing horizontal vs vertical penetration.
/// Later corners overwrite the direction, exactly like the original.
public func classifyCollision(src: IRect, dest: IRect) -> Collision? {
  if src.x + src.width < dest.x { return nil }
  if src.y + src.height < dest.y { return nil }
  if src.x > dest.x + dest.width { return nil }
  if src.y > dest.y + dest.height { return nil }

  var dir = CollisionDirection.down
  var found = false

  let bottomRight = IPoint(x: src.x + src.width, y: src.y + src.height)
  let bottomLeft = IPoint(x: src.x, y: src.y + src.height)
  let topRight = IPoint(x: src.x + src.width, y: src.y)
  let topLeft = IPoint(x: src.x, y: src.y)

  if dest.contains(bottomRight) {
    found = true
    let w = bottomRight.x - dest.x
    let h = bottomRight.y - dest.y
    if w > h { dir = .up } else if h > w { dir = .left } else { dir = .topLeft }
  }
  if dest.contains(bottomLeft) {
    found = true
    let w = dest.x + dest.width - bottomLeft.x
    let h = bottomLeft.y - dest.y
    if w > h { dir = .up } else if h > w { dir = .right } else { dir = .topRight }
  }
  if dest.contains(topRight) {
    found = true
    let w = topRight.x - dest.x
    let h = dest.y + dest.height - topRight.y
    if w > h { dir = .down } else { dir = .left }
  }
  if dest.contains(topLeft) {
    found = true
    let w = dest.x + dest.width - topLeft.x
    let h = dest.y + dest.height - topLeft.y
    if w > h { dir = .down } else { dir = .right }
  }

  guard found else { return nil }
  return Collision(src: src, dest: dest, dir: dir)
}
