//
//  SearchController+Extended.swift
//  WallapopMarvel
//
//  Created by Timothy  on 24/05/2022.
//

import Combine
import Foundation
import UIKit

protocol CombineCompatible {}
extension UIControl: CombineCompatible {}
extension CombineCompatible where Self: UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: events)
    }
}

/// A custom subscription to capture UIControl target events.
final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription
    where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

/// A custom `Publisher` to work with our custom `UIControlSubscription`.
struct UIControlPublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }

    func receive<S>(subscriber: S) where S: Subscriber,
                                            S.Failure == UIControlPublisher.Failure,
                                         S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

public extension Publisher {
    func flatMap<Weak, TransformedOutput>(
        maxPublishers: Subscribers.Demand = .unlimited,
        weak: Weak,
        _ transform: @escaping (Weak, Self.Output) -> AnyPublisher<TransformedOutput, Failure>
    ) -> Publishers.FlatMap<AnyPublisher<TransformedOutput, Failure>, Self>
        where Weak: AnyObject, Failure: UnknownErrorHaving {
        flatMap(maxPublishers: maxPublishers) { [weak weak] output in
            guard let strong = weak else { return Fail(error: Failure.unknown).eraseToAnyPublisher() }
            return transform(strong, output)
        }
    }

    func assign<SubjectType>(
        to subject: SubjectType
    ) -> AnyCancellable where SubjectType: Subject,
        SubjectType.Output == Self.Output,
        SubjectType.Failure == Self.Failure {
        sink { completion in
            subject.send(completion: completion)
        } receiveValue: { output in
            subject.send(output)
        }
    }

    func assignError<SubjectType>(
        to subject: SubjectType
    ) -> AnyPublisher<Output, Failure> where SubjectType: Subject, SubjectType.Output == Self.Failure {
        return mapError { error in
            subject.send(error)
            return error
        }
        .eraseToAnyPublisher()
    }

    func assignError<SubjectType>(
        to subject: SubjectType
    ) -> AnyPublisher<Output, Failure> where SubjectType: Subject, SubjectType.Output == Self.Failure? {
        return mapError { error in
            subject.send(error)
            return error
        }
        .map { output in
            subject.send(nil)
            return output
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher {
    func skipNil<Wrapped>() -> Publishers.CompactMap<Self, Wrapped> where Self.Output == Wrapped? {
        return compactMap { output in output }
    }
}

public extension Publisher {
    func compactMap<Type>(
        as type: Type.Type
    ) -> Publishers.CompactMap<Self, Type> {
        return compactMap { output in output as? Type }
    }
    func compactMapError<ErrorType: Error>(
        as type: ErrorType.Type
    ) -> Publishers.MapError<Self, ErrorType> {
        return mapError { error in forceCast(error, as: ErrorType.self) }
    }
}
public extension Publisher where Self.Failure == Never {
    func sink<WeakType>(
        weak: WeakType,
        receiveValue: @escaping (WeakType, Self.Output) -> Void
    ) -> AnyCancellable where WeakType: AnyObject {
        sink { [weak weak] value in
            guard let strong = weak else { return }
            receiveValue(strong, value)
        }
    }
}
public extension Publishers.CombineLatest where Self.Failure == Never {
    func sink<WeakType>(
        weak: WeakType,
        receiveValue: @escaping (WeakType, A.Output, B.Output) -> Void
    ) -> AnyCancellable where WeakType: AnyObject {
        sink { [weak weak] value in
            guard let strong = weak else { return }
            receiveValue(strong, value.0, value.1)
        }
    }
}
public extension Publishers.CombineLatest3 where Self.Failure == Never {
    func sink<WeakType>(
        weak: WeakType,
        receiveValue: @escaping (WeakType, A.Output, B.Output, C.Output) -> Void
    ) -> AnyCancellable where WeakType: AnyObject {
        sink { [weak weak] value in
            guard let strong = weak else { return }
            receiveValue(strong, value.0, value.1, value.2)
        }
    }
}
extension AnyPublisher {
    static func just(_ output: Output) -> Self {
        Just(output)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    static func fail(with error: Failure) -> Self {
        Fail(outputType: Output.self, failure: error)
            .eraseToAnyPublisher()
    }

    static func deferredFuture<Weak: AnyObject>(
        weak: Weak,
        _ closure: @escaping (Weak, @escaping Future<Output, Failure>.Promise) -> Void
    ) -> AnyPublisher<Output, Failure> {
        return Deferred { [weak weak] in
            Future { [weak weak] promise in
                guard let strong = weak else { return }
                closure(strong, promise)
            }
        }
        .eraseToAnyPublisher()
    }
}
extension Publisher where Failure: UnknownErrorHaving {
    func typedTryMap<T>(
        _ transform: @escaping (Output) throws -> T
    ) -> AnyPublisher<T, Failure> {
        return tryMap { output in
            do {
                return try transform(output)
            } catch let error as Failure {
                throw error
            } catch {
                throw Failure.unknown
            }
        }
        .mapError { forceCast($0, as: Failure.self) }
        .eraseToAnyPublisher()
    }
    func replaceNil<Output>(
        withError error: Failure
    ) -> AnyPublisher<Output, Failure> where Self.Output == Output?, Failure: UnknownErrorHaving {
        typedTryMap { output in
            if let output = output {
                return output
            } else {
                throw error
            }
        }
        .eraseToAnyPublisher()
    }

    func typedTryCatch<P>(
        _ handler: @escaping (Self.Failure) throws -> P
    ) -> AnyPublisher<Self.Output, Failure>
        where P: Publisher, Self.Output == P.Output, P.Failure == Failure {
        return typedTryCatch(nextFailureType: Failure.self, handler)
    }
}
extension Publisher {
    func typedTryCatch<P, NextFailure>(
        nextFailureType: NextFailure.Type,
        _ handler: @escaping (Self.Failure) throws -> P
    ) -> AnyPublisher<Self.Output, NextFailure>
        where P: Publisher, Self.Output == P.Output, P.Failure == NextFailure, NextFailure: UnknownErrorHaving {
        return tryCatch { error -> P in
            do {
                return try handler(error)
            } catch let error as NextFailure {
                throw error
            } catch {
                throw NextFailure.unknown
            }
        }
        .mapError { forceCast($0, as: NextFailure.self) }
        .eraseToAnyPublisher()
    }
}
extension Publisher where Failure == Never {
    func replaceNil<Output, NewFailure>(
        withError error: NewFailure
    ) -> AnyPublisher<Output, NewFailure> where Self.Output == Output? {
        setFailureType(to: NewFailure.self)
            .tryMap { output in
                if let output = output {
                    return output
                } else {
                    throw error
                }
            }
            .mapError { _ in error }
            .eraseToAnyPublisher()
    }
}
extension Publisher {
    func forEach<Element, TransformedOutput>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Element) -> AnyPublisher<TransformedOutput, Failure>
    ) -> AnyPublisher<TransformedOutput, Failure> where Output == [Element] {
        flatMap(maxPublishers: maxPublishers) { (output: [Element]) -> AnyPublisher<Element, Failure> in
            output.publisher.setFailureType(to: Failure.self).eraseToAnyPublisher()
        }
        .flatMap { element in
            transform(element)
        }
        .eraseToAnyPublisher()
    }

    func forEach<Element>(
        maxPublishers: Subscribers.Demand = .unlimited
    ) -> AnyPublisher<Element, Failure> where Output == [Element] {
        flatMap(maxPublishers: maxPublishers) { (output: [Element]) -> AnyPublisher<Element, Failure> in
            output.publisher.setFailureType(to: Failure.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
/// Converts throwing call to assertion
@discardableResult
public func assertNoThrow<T>(_ message: @autoclosure () -> String, _ closure: () throws -> T) -> T? {
    do {
        return try closure()
    } catch {
        assertionFailure(message() + "\n" + error.localizedDescription)
        return nil
    }
}
public func forceCast<T, U>(_ object: T, as _: U.Type, file: StaticString = #file, line: UInt = #line) -> U {
    guard let result = object as? U else {
        fatalError("Force cast failed: expected \(U.self), got \(type(of: object))", file: file, line: line)
    }
    return result
}

enum CastError: Error {
    case castFailed(description: String)
}
extension UISearchTextField {
    func setupSearchBarListener() -> AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self)
            .map {
                ($0.object as? UISearchTextField)?.text
            }
            .eraseToAnyPublisher()
    }
}
