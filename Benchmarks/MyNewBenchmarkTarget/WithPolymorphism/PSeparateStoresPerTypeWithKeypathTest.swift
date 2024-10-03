private protocol Syntax {
  func getProductWith(n: Int) -> Int

  static var path: WritableKeyPath<Program, [Self]> { get }
}

extension Syntax {
  fileprivate typealias ID = SyntaxID<Self>
}

private struct A: Syntax {
  static var path: WritableKeyPath<Program, [Self]> = \.a
  let v: Int
  let w: Int
  let q: Int
  let r: Int
  let t: Int
  let u: Int
  let i: Int
  let o: Int
  let p: Int
  let a: Int
  let s: Int
  let d: Int

  func getProductWith(n: Int) -> Int {
    return v * w - q * r + t * u - i * o + p * a - s + d * n
  }
}

private struct B: Syntax {
  static var path: WritableKeyPath<Program, [Self]> = \.b
  let v: Int
  let w: Int
  let q: Int
  let r: Int

  func getProductWith(n: Int) -> Int {
    return v * w - q * r + n
  }
}

private struct C: Syntax {
  static var path: WritableKeyPath<Program, [Self]> = \.c
  let x: Int
  let y: Int
  let z: Int
  let w: Int
  let q: Int
  let r: Int
  let t: Int
  let u: Int
  let i: Int
  let o: Int

  func getProductWith(n: Int) -> Int {
    return x * y + z - w * q + r * t + u - i + o * n
  }
}

private struct SyntaxID<T: Syntax> {
  var raw: Int
  init(_ raw: Int) { self.raw = raw }
}

private struct Program {

  var a: [A] = []
  var b: [B] = []
  var c: [C] = []

  init() {}

  // monomorphisable
  subscript<T: Syntax>(i: T.ID) -> T {
    self[keyPath: T.path][i.raw]
  }

  mutating func insert<T: Syntax>(_ n: T) -> T.ID {
    modify(&self[keyPath: T.path]) { (ns) in
      ns.append(n)
      return .init(ns.count - 1)
    }
  }

  // polymorphic
  subscript(_ id: AnySyntaxID) -> (any Syntax) {
    switch id {
    case .a(let id):
      return a[id.raw]
    case .b(let id):
      return b[id.raw]
    case .c(let id):
      return c[id.raw]
    }
  }

  mutating func insertAny(_ syntax: (any Syntax)) -> AnySyntaxID {
    switch syntax {
    case let a as A:
      return .a(insert(a))
    case let b as B:
      return .b(insert(b))
    case let c as C:
      return .c(insert(c))
    default:
      fatalError()
    }
  }

}

private func modify<T, U>(_ v: inout T, _ action: (inout T) -> U) -> U {
  action(&v)
}

private enum AnySyntaxID {
  case a(SyntaxID<A>)
  case b(SyntaxID<B>)
  case c(SyntaxID<C>)

  var raw: Int {
    switch self {
    case .a(let id): return id.raw
    case .b(let id): return id.raw
    case .c(let id): return id.raw
    }
  }
}

  func PSeparateStoresPerTypeWithKeypathTesttestPolymorphicMethodDispatch() {
    var p = Program()
    var num: UInt = 0
    var list: [AnySyntaxID] = []
    var sum = 0

    for _ in 0..<100000 {
      num += 2432
      num *= 39
      num %= 1_000_001

      if num % 3 == 0 {
        list.append(
          .a(
            p.insert(
              A(v: 0, w: 1, q: 2, r: 3, t: 4, u: 5, i: 6, o: 7, p: 8, a: 9, s: 10, d: 11))))
      } else if num % 3 == 1 {
        list.append(.b(p.insert(B(v: Int(num), w: 1, q: 2, r: 3))))
      } else {
        list.append(
          .c(
            p.insert(
              C(
                x: Int(num), y: Int(num + 1), z: Int(num + 2), w: Int(num + 3), q: Int(num + 4),
                r: Int(num + 5), t: Int(num + 6), u: Int(num + 7), i: Int(num + 8),
                o: Int(num + 9))
            )))
      }
    }

    for _ in 0..<100000 {
      num += 2432
      num *= 39
      num %= 1_000_001

      sum += p[list[Int(num) % list.count]].getProductWith(n: Int(num) % 100)
    }
  
    // assertEqual(p.a.count + p.b.count + p.c.count, 100000)
    // assertEqual(sum, 1130775979938052742)

  }

  func PSeparateStoresPerTypeWithKeypathTesttestPolymorphicInsertion() {
    var num: UInt = 0

    var sum = 0

    var listToInsert: [any Syntax] = []

    for _ in 0..<100000 {
      num += 2432
      num *= 39
      num %= 1_000_001

      if num % 3 == 0 {
        listToInsert.append(
          A(v: 0, w: 1, q: 2, r: 3, t: 4, u: 5, i: 6, o: 7, p: 8, a: 9, s: 10, d: 11))
      } else if num % 3 == 1 {
        listToInsert.append(B(v: Int(num), w: 1, q: 2, r: 3))
      } else {
        listToInsert.append(
          C(
            x: Int(num), y: Int(num + 1), z: Int(num + 2), w: Int(num + 3), q: Int(num + 4),
            r: Int(num + 5), t: Int(num + 6), u: Int(num + 7), i: Int(num + 8), o: Int(num + 9))
        )
      }
    }

    printTimeElapsedWhenRunningCode(title: "dasss keypath \t | polymorphic insertion", runs: 10){
      sum = 0
      var p = Program()
      for i in stride(from: listToInsert.count - 1, to: -1, by: -1) {
        sum += p.insertAny(listToInsert[i]).raw
      }
    }
    // assertEqual(sum, 16675293210891)
  }
