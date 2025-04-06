/// A protocol defining a type that handles actions to produce state mutations in a unidirectional data flow architecture.
///
/// `Reducer` is a fundamental part of state management, where it takes the current state and an action, and produces
/// a new state or effects that may lead to further actions. This design promotes immutability and clear separation of concerns.
///
/// - Parameters:
///   - Action: The type representing all possible actions that can trigger state changes.
///   - State: The type representing the state of the system.
public protocol Reducer<Action, State>: Sendable {
    
    /// The type representing all actions that can be dispatched to the reducer.
    associatedtype Action: Sendable
    
    /// The type representing the current state managed by the reducer.
    associatedtype State: Sendable

    /// Applies an action to the current state and returns an optional effect.
    ///
    /// This method is called whenever an action is dispatched. The reducer modifies the state based on the action and
    /// can return an effect that performs additional asynchronous work, potentially leading to further actions.
    ///
    /// - Parameters:
    ///   - state: The current state of the system. This parameter is marked `inout` to allow mutations.
    ///   - action: The action that was dispatched.
    /// - Returns: An optional effect that may trigger additional actions.
    func reduce(state: inout State, action: Action) -> (any Effect<Action>)?
    
}
