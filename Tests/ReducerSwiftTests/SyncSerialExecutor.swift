import Foundation

@available(iOS 18.0, *)
@available(macOS 15.0, *)
final class SyncSerialExecutor: TaskExecutor, SerialExecutor {
    let queue = DispatchQueue.main
    
    func enqueue(_ job: UnownedJob) {
        guard Thread.isMainThread else {
            return queue.sync {
                job.runSynchronously(
                    isolatedTo: self.asUnownedSerialExecutor(),
                    taskExecutor: self.asUnownedTaskExecutor()
                )
            }
        }
        
        job.runSynchronously(
            isolatedTo: self.asUnownedSerialExecutor(),
            taskExecutor: self.asUnownedTaskExecutor()
        )
    }
    
    func asUnownedTaskExecutor() -> UnownedTaskExecutor {
        UnownedTaskExecutor(ordinary: self)
    }
    
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

@available(iOS 18.0, *)
@available(macOS 15.0, *)
@globalActor
actor AsyncTester {
    static var shared = AsyncTester()
    
    static let executor = SyncSerialExecutor()
    
    static var sharedUnownedExecutor: UnownedSerialExecutor { executor
        .asUnownedSerialExecutor()
    }
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.sharedUnownedExecutor
    }
}
