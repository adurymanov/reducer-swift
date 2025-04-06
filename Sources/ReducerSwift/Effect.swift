/// A protocol representing an asynchronous side effect that can produce an action.
///
/// `Effect` encapsulates work that might take time to complete, such as API calls or database queries.
/// When the work is finished, the effect produces an action that can be dispatched back to the system.
/// This allows effects to drive the state of the application in response to external processes.
///
/// - Parameters:
///   - Action: The type representing the action that the effect produces upon completion.
public protocol Effect<Action>: Sendable {
    
    /// The type representing the action that the effect can emit.
    associatedtype Action: Sendable

    /// Executes the asynchronous work and returns an optional action.
    ///
    /// This method performs the side effect and may return an action that will be dispatched to the reducer.
    /// If no action needs to be produced, the method can return `nil`.
    ///
    /// - Returns: An optional action produced by the effect.
    func run() async -> Action?
    
}
