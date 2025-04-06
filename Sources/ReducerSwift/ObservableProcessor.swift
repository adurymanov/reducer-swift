import Observation

/// The class process an reducer actions, hold a reducer state and run reducer side effects.
///
/// Usage example:
/// ```swift
/// struct SomeView: View {
///
///     @State var processor = ObservableProcessor(initialState: .none, reducer: GestureReducer())
///
///     var body: some View {
///         Text("view").onTapGesture {
///             processor.send(action: .tap)
///         }.onLongPressGesture {
///             processor.send(action: .longPress)
///         }
///         .onChange(of: processor.state) { newValue in
///             print("new reducer state: \(newValue)")
///         }
///     }
///
/// }
/// ```
@MainActor @Observable public final class ObservableProcessor<R: Reducer>: Sendable where R.State: Sendable {
    
    public var state: R.State
    
    private let reducer: R
    
    public init(initialState: R.State, reducer: R) {
        self.state = initialState
        self.reducer = reducer
    }
    
    /// The method sends new action to reducer
    public func send(action: R.Action) {
        if let effect = reducer.reduce(state: &state, action: action) {
            run(effect: effect)
        }
    }
    
    private func run(effect: any Effect<R.Action>) {
        Task {
            if let action = await effect.run() {
                send(action: action)
            }
        }
    }
    
}
