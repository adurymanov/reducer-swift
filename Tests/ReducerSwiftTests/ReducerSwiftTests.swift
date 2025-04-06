import Testing
import Observation
@testable import ReducerSwift

// MARK: - Mocks

@available(iOS 18.0, *)
@available(macOS 15.0, *)
@AsyncTester
private final class TestEffect: Effect {
    
    var runCallCount = 0
    
    func run() async -> Int? {
        runCallCount += 1
        return nil
    }
}

@available(iOS 18.0, *)
@available(macOS 15.0, *)
private final class TestReducer: Reducer, @unchecked Sendable {
    typealias State = Int
    typealias Action = Int
    
    var effect: TestEffect?
        
    var reducerCallCount = 0
    
    func reduce(state: inout State, action: Action) -> (any Effect<Action>)? {
        state += action * 10
        reducerCallCount += 1
        return effect
    }
    
    func set(effect: TestEffect) {
        self.effect = effect
    }
    
}

// MARK: - Tests

struct ProcessorTests {
    
    @Test(.timeLimit(.minutes(1)))
    @available(macOS 15.0, *)
    @available(iOS 18.0, *)
    @AsyncTester
    func testProcesstorReducerCall() async {
        await withTaskExecutorPreference(AsyncTester.executor) {
            // Given
            let callCount = 10
            let reducer = TestReducer()
            let processor = Processor(
                initialState: .zero,
                reducer: reducer
            )
            
            var reducerCallCount = 0
            
            // When
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<callCount {
                    group.addTask {
                        processor.send(action: i)
                    }
                }
            }
            
            for await _ in processor.state {
                reducerCallCount += 1
                
                if reducerCallCount == callCount { break }
            }
            
            // Then
            #expect(reducerCallCount == callCount)
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    @available(macOS 15.0, *)
    @available(iOS 18.0, *)
    @AsyncTester
    func testProcessorEffectCall() async {
        // Given
        let callCount = 10
        let reducer = TestReducer()
        let effect = TestEffect()
        
        reducer.set(effect: effect)
        var reducerCallCount = 0
        
        let processor = Processor(
            initialState: .zero,
            reducer: reducer
        )
        
        // When
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<callCount {
                group.addTask {
                    processor.send(action: i)
                }
            }
        }
        
        for await _ in processor.state {
            reducerCallCount += 1
            
            if reducerCallCount == callCount { break }
        }
        
        // Then
        try? await Task.sleep(nanoseconds: 1_000_000)
        #expect(effect.runCallCount > 0)
    }

    @Test(.timeLimit(.minutes(1)))
    @available(macOS 15.0, *)
    @available(iOS 18.0, *)
    @AsyncTester
    func processorStateUpdates() async {
        // Given
        
        let expectedState = 10
        let reducer = TestReducer()
        let effect = TestEffect()
        
        reducer.set(effect: effect)
        
        let processor = Processor(
            initialState: .zero,
            reducer: reducer
        )
        
        // When
        
        let resultTask = Task {
            var result: Int?
            for await state in processor.state {
                print(state)
                result = state
                break
            }
            return result
        }
        
        processor.send(action: 1)
        
        // Then
        
        await #expect(resultTask.value == expectedState)
    }
    
}
