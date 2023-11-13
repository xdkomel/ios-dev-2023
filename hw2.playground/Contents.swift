class LinkedList<T>: CustomStringConvertible {
    private var head: Node<T>?
    
    init() {
        head = nil
    }
    
    func append(_ value: T) {
        guard let headVal = head else {
            head = Node(value: value)
            return
        }
        append(value, node: headVal)
    }
    
    private func append(_ value: T, node: Node<T>) {
        guard let next = node.next else {
            node.next = Node(value: value)
            return
        }
        append(value, node: next)
    }
    
    func toArray() -> [T] {
        guard let headVal = head else {
            return []
        }
        return toArray(headVal)
    }
    
    private func toArray(_ node: Node<T>) -> [T] {
        guard let next = node.next else {
            return [node.value]
        }
        return [node.value] + toArray(next)
    }
    
    var description: String {
        guard let headVal = head else {
            return "Empty LinkedList"
        }
        return buildDescription(headVal)
    }
    
    private func buildDescription(_ node: Node<T>) -> String {
        guard let next = node.next else {
            return "\(node.value)"
        }
        return "\(node.value) -> \(buildDescription(next))"
    }
}

class Node<T> {
    var value: T
    var next: Node<T>?
    
    init(value: T, next: Node<T>) {
        self.value = value
        self.next = next
    }
    
    init(value: T) {
        self.value = value
        next = nil
    }
}

extension Sequence {
    func toLinkedList() -> LinkedList<Element> {
        let list = LinkedList<Element>()
        forEach(list.append)
        return list
    }
}

let list = LinkedList<Int>()
list.append(1)
list.append(2)
list.append(3)
list.append(4)

// Print data in the linked list
print(list)

// Convert it to an array
print(list.toArray())

let arr = [10, 11, 12, 13, 14, 15]
// Convert an array to the linked list
print(arr.toLinkedList())




protocol LinkedListProducer {
    associatedtype T
    associatedtype Container: Sequence
    func produceLinkedList(from source: Container) -> LinkedList<T>
}

private class _AnyLinkedListProducerBox<T, Container>: LinkedListProducer where Container: Sequence {
    func produceLinkedList(from source: Container) -> LinkedList<T> {
        fatalError("This method is abstract")
    }
}

private class _LinkedListProducerBox<Base: LinkedListProducer>: _AnyLinkedListProducerBox<Base.T, Base.Container> {
    private let _base: Base
    
    init(_ base: Base) {
        _base = base
    }
    
    override func produceLinkedList(from source: Base.Container) -> LinkedList<Base.T> {
        _base.produceLinkedList(from: source)
    }
}

class AnyLinkedListProducer<T, Container>: LinkedListProducer where Container: Sequence {
    private let _box: _AnyLinkedListProducerBox<T, Container>
    
    init<ProducerType: LinkedListProducer>(_ producer: ProducerType) where ProducerType.T == T, ProducerType.Container == Container {
        _box = _LinkedListProducerBox(producer)
    }
    
    func produceLinkedList(from source: Container) -> LinkedList<T> {
        _box.produceLinkedList(from: source)
    }
}

class LinkedListArrayService<T> {
    typealias Container = Array<T>
    
    let producer: AnyLinkedListProducer<T, Container>
    
    init(producer: AnyLinkedListProducer<T, Container>) {
        self.producer = producer
    }
    
    func produceLinkedList(from array: Container) -> LinkedList<T> {
        return producer.produceLinkedList(from: array)
    }
}

class LinkedListIntsArrayProducer: LinkedListProducer {
    typealias T = Int
    typealias Container = Array<Int>
    
    func produceLinkedList(from source: Array<Int>) -> LinkedList<Int> {
        return source.toLinkedList()
    }
}

let producer = AnyLinkedListProducer(LinkedListIntsArrayProducer())
let linkedListService = LinkedListArrayService<Int>(producer: producer)

// Print the result of producing
print(linkedListService.produceLinkedList(from: [1, 2, 3, 4, 5]))
