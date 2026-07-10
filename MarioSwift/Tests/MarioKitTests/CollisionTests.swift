import Testing

@testable import MarioKit

@Suite("Collision classification (legacy Level.Intersects port)")
struct CollisionTests {
  let block = IRect(x: 100, y: 100, width: 16, height: 16)

  @Test func noOverlapReturnsNil() {
    #expect(classifyCollision(src: IRect(x: 0, y: 0, width: 16, height: 16), dest: block) == nil)
    #expect(classifyCollision(src: IRect(x: 100, y: 200, width: 16, height: 16), dest: block) == nil)
  }

  @Test func landingOnTopIsUp() {
    // Mario-sized source standing exactly on the block's top edge.
    let src = IRect(x: 102, y: 84, width: 16, height: 16)
    let collision = classifyCollision(src: src, dest: block)
    #expect(collision?.dir == .up)
  }

  @Test func touchingEdgesCollide() {
    // Bottom edge == top edge still collides (inclusive containment); the
    // game relies on this for standing on blocks without jitter.
    let src = IRect(x: 100, y: 84, width: 16, height: 16)
    #expect(classifyCollision(src: src, dest: block) != nil)
  }

  @Test func wallOnRightIsLeft() {
    // Source overlapping the block's left side, mostly vertical overlap →
    // `.left` (in legacy terms: push the source left).
    let src = IRect(x: 87, y: 100, width: 16, height: 16)
    let collision = classifyCollision(src: src, dest: block)
    #expect(collision?.dir == .left)
  }

  @Test func wallOnLeftIsRight() {
    let src = IRect(x: 113, y: 100, width: 16, height: 16)
    let collision = classifyCollision(src: src, dest: block)
    #expect(collision?.dir == .right)
  }

  @Test func headBumpIsDown() {
    // Source rising into the block from below.
    let src = IRect(x: 102, y: 113, width: 16, height: 16)
    let collision = classifyCollision(src: src, dest: block)
    #expect(collision?.dir == .down)
  }
}
