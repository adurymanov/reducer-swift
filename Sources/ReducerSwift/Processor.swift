import AsyncAlgorithms

/// The class process an reducer actions, hold a reducer state and run reducer side effects.
///
/// Usage example:
/// ```swift
/// let reducer: some Reducer = ...
/// let processor = Processor(initialState: .none, reducer: reducer)
///
/// Task {
///     for await state in processor.state {
///        print("next state \(state)")
///     }
/// }
///
/// processor.send(action: .touch(Position(x: 10, y: 20))
/// processor.send(action: .touch(Position(x: 15, y: 20))
/// processor.send(action: .touch(Position(x: 20, y: 20))
/// ```
public final class Processor<R: Reducer>: Sendable {
    
    public typealias StateStream = AsyncStream<R.State>
    
    private typealias ActionStream = AsyncStream<R.Action>
    
    private typealias EventStream = AsyncStream<(any Effect<R.Action>)?>
    
    public var state: StateStream {
        output.stream
    }
    
    private let output: (stream: StateStream, continuation: StateStream.Continuation)
    
    private let events: (stream: EventStream, continuation: EventStream.Continuation)
    
    private let actions: (stream: ActionStream, continuation: ActionStream.Continuation)
    
    private let reducer: R
    
    /// The processor for a reducer
    ///
    /// - Parameters:
    ///     - initialState: The base of reducing
    ///     - reducer: The reducer
    public init(initialState: R.State, reducer: R) {
        self.reducer = reducer
        
        self.events = EventStream.makeStream()
        self.actions = ActionStream.makeStream(bufferingPolicy: .unbounded)
        self.output = StateStream.makeStream()
        
        startListenActions(initialState: initialState)
        startListenEvents()
    }
    
    /// Send a new action to reducer
    public func send(action: R.Action) {
        actions.continuation.yield(action)
    }
    
    private func startListenActions(initialState: R.State) {
        let stream = actions.stream.reductions(into: (initialState, Optional<any Effect<R.Action>>.none)) { [reducer] result, action in
            result.1 = reducer.reduce(
                state: &result.0,
                action: action
            )
        }
        Task(priority: .userInitiated) {
            for await (state, effect) in stream {
                guard !Task.isCancelled else { return }
                self.output.continuation.yield(state)
                self.events.continuation.yield(effect)
            }
        }
    }
    
    private func startListenEvents() {
        Task {
            for await effect in events.stream.compacted() {
                guard !Task.isCancelled else { return }
                await run(effect: effect)
            }
        }
    }
    
    private func run(effect: any Effect<R.Action>) async {
        if let action = await effect.run() {
            send(action: action)
        }
    }
    
}
