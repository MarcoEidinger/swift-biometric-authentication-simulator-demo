import Foundation
import LocalAuthentication

func localAuthenticationInSimulator<T>(
    evaluating policy: LAPolicy = .deviceOwnerAuthentication,
    on context: LAContext = LAContext(),
    beforeCalling function: @escaping () -> T?
) async -> T? {
#if targetEnvironment(simulator)
    var localizedReason = context.localizedReason
    if localizedReason.isEmpty {
        localizedReason = "Test in simulator"
        context.localizedReason = localizedReason
    }
    guard context.canEvaluatePolicy(policy, error: nil) else { return nil }
    do {
        guard try await context.evaluatePolicy(policy, localizedReason: localizedReason) else { return nil }
        return function()
    } catch {
        return nil
    }
#else
    return function()
#endif
}

func localAuthenticationInSimulator<T>(
    evaluating policy: LAPolicy = .deviceOwnerAuthentication,
    on context: LAContext = LAContext(),
    beforeCalling function: @escaping () -> T?,
    _ completionHandler: @escaping (T?) -> Void
) {
    #if targetEnvironment(simulator)
        let savedCompletionHandler = completionHandler
        var localizedReason = context.localizedReason
        if localizedReason.isEmpty {
            localizedReason = "Test in simulator"
            context.localizedReason = localizedReason
        }
        if context.canEvaluatePolicy(policy, error: nil) {
            context.evaluatePolicy(policy, localizedReason: localizedReason) { result, error in
                if error != nil {
                    savedCompletionHandler(nil)
                } else if result {
                    savedCompletionHandler(function())
                } else {
                    savedCompletionHandler(nil)
                }
            }
        } else {
            return completionHandler(nil)
        }
    #else
        completionHandler(function())
    #endif
}
