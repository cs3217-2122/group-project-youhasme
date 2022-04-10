//
//  Graph.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import Foundation

// taken from https://github.com/raywenderlich/swift-algorithm-club/tree/master/Graph/Graph
public struct Edge<T>: Equatable where T: Hashable {

  public let from: Vertex<T>
  public let to: Vertex<T>

  public let weight: Double?

}

public struct Vertex<T>: Equatable where T: Hashable {

  public var data: T
  public let index: Int

}

extension Vertex: CustomStringConvertible {

  public var description: String {
    "\(index): \(data)"
  }

}

extension Vertex: Hashable {

  public func hasher(into hasher: inout Hasher) {
    hasher.combine(data)
    hasher.combine(index)
  }

}

public func ==<T>(lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
  guard lhs.index == rhs.index else {
    return false
  }

  guard lhs.data == rhs.data else {
    return false
  }

  return true
}

extension Edge: CustomStringConvertible {

  public var description: String {
    guard let unwrappedWeight = weight else {
      return "\(from.description) -> \(to.description)"
    }
    return "\(from.description) -(\(unwrappedWeight))-> \(to.description)"
  }

}

extension Edge: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(from)
    hasher.combine(to)
    if weight != nil {
      hasher.combine(weight)
    }
  }

}

public func == <T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
  guard lhs.from == rhs.from else {
    return false
  }

  guard lhs.to == rhs.to else {
    return false
  }

  guard lhs.weight == rhs.weight else {
    return false
  }

  return true
}
private class EdgeList<T> where T: Hashable {

  var vertex: Vertex<T>
  var edges: [Edge<T>]?

  init(vertex: Vertex<T>) {
    self.vertex = vertex
  }

  func addEdge(_ edge: Edge<T>) {
    edges?.append(edge)
  }

}

open class AbstractGraph<T>: CustomStringConvertible where T: Hashable {

  public required init() {}

  public required init(fromGraph graph: AbstractGraph<T>) {
    for edge in graph.edges {
      let from = createVertex(edge.from.data)
      let to = createVertex(edge.to.data)

      addDirectedEdge(from, to: to, withWeight: edge.weight)
    }
  }

  open var description: String {
    fatalError("abstract property accessed")
  }

  open var vertices: [Vertex<T>] {
    fatalError("abstract property accessed")
  }

  open var edges: [Edge<T>] {
    fatalError("abstract property accessed")
  }

  // Adds a new vertex to the matrix.
  // Performance: possibly O(n^2) because of the resizing of the matrix.
  open func createVertex(_ data: T) -> Vertex<T> {
    fatalError("abstract function called")
  }

  open func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
    fatalError("abstract function called")
  }

  open func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
    fatalError("abstract function called")
  }

  open func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
    fatalError("abstract function called")
  }

  open func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
    fatalError("abstract function called")
  }
}

open class AdjacencyListGraph<T>: AbstractGraph<T> where T: Hashable {

  fileprivate var adjacencyList: [EdgeList<T>] = []

  public required init() {
    super.init()
  }

  public required init(fromGraph graph: AbstractGraph<T>) {
    super.init(fromGraph: graph)
  }

  override open var vertices: [Vertex<T>] {
    var vertices = [Vertex<T>]()
    for edgeList in adjacencyList {
      vertices.append(edgeList.vertex)
    }
    return vertices
  }

  override open var edges: [Edge<T>] {
    var allEdges = Set<Edge<T>>()
    for edgeList in adjacencyList {
      guard let edges = edgeList.edges else {
        continue
      }

      for edge in edges {
        allEdges.insert(edge)
      }
    }
    return Array(allEdges)
  }

  override open func createVertex(_ data: T) -> Vertex<T> {
    // check if the vertex already exists
    let matchingVertices = vertices.filter { vertex in
      vertex.data == data
    }

    if matchingVertices.count > 0 {
      return matchingVertices.last!
    }

    // if the vertex doesn't exist, create a new one
    let vertex = Vertex(data: data, index: adjacencyList.count)
    adjacencyList.append(EdgeList(vertex: vertex))
    return vertex
  }

  override open func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
    // works
    let edge = Edge(from: from, to: to, weight: weight)
    let edgeList = adjacencyList[from.index]
    if edgeList.edges != nil {
        edgeList.addEdge(edge)
    } else {
        edgeList.edges = [edge]
    }
  }

  override open func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
    addDirectedEdge(vertices.0, to: vertices.1, withWeight: weight)
    addDirectedEdge(vertices.1, to: vertices.0, withWeight: weight)
  }

  override open func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
    guard let edges = adjacencyList[sourceVertex.index].edges else {
      return nil
    }

    for edge: Edge<T> in edges {
      if edge.to == destinationVertex {
        return edge.weight
      }
    }

    return nil
  }

  override open func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
    adjacencyList[sourceVertex.index].edges ?? []
  }

  override open var description: String {
    var rows = [String]()
    for edgeList in adjacencyList {

      guard let edges = edgeList.edges else {
        continue
      }

      var row = [String]()
      for edge in edges {
        var value = "\(edge.to.data)"
        if edge.weight != nil {
          value = "(\(value): \(edge.weight!))"
        }
        row.append(value)
      }

      rows.append("\(edgeList.vertex.data) -> [\(row.joined(separator: ", "))]")
    }

    return rows.joined(separator: "\n")
  }
}
