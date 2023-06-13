
import Foundation

/// DIコンテナ インスタンス
public let container = DIContainer()

public class DIContainer {
    private var dependencies: [String: () -> Any?] = [:]
    private var singletons: [String: Any?] = [:]
    
    public func register<T>(_ type: T.Type, _ lifeCycle: LifeCycle = .default, _ resolve: @escaping () -> T) {
        switch lifeCycle {
        case .default:
            dependencies[String(describing: type)] = resolve
        case .singleton:
            singletons[String(describing: type)] = resolve()
        }
    }
    
    /// インスタンスを生成して返します。
    /// register時にlifeCycleをsingletonにしていた場合は、すでにあるインスタンスを返します。
    public func resolve<T>(_ type: T.Type) -> T {
        if let instance = singletons[String(describing: type)] as? T {
            return instance
        }
        
        if let instance = dependencies[String(describing: type)]?() as? T {
            return instance
        }
        
        fatalError("resolveする前にregisterしてください: \(String(describing: type))")
    }
    
    public enum LifeCycle {
        /// 依存性解決時にインスタンス生成します
        case `default`
        /// インスタンスは1つだけ
        case singleton
    }
}
