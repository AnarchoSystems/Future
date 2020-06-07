//
//  Actor.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



open class Agent{
    
    open var queue = DispatchQueue(label: "AgentQueue")
    private var error : Error?{
        didSet{
            guard let reason = error else{
                return
            }

            let mirror = Mirror(reflecting: self)
            for child in mirror.children{
                let m = Mirror(reflecting: child.value)
                for c in m.children{
                    if let cheat = c.value as? CheatTypeForMirror<Self>{
                        cheat.setCrash(reason)
                    }
                    if
                        let downstreamAgent = c.value as? Agent{
                        downstreamAgent.upstreamAgentDidCrashWrapper.send((agent: self, reason: reason))
                    }
                }
            }
            onCrashWrapper.send(reason)
        }
    }
    
    public init(){
        let mirror = Mirror(reflecting: self)
        for child in mirror.children{
            let m = Mirror(reflecting: child.value)
            for c in m.children{
                if let cheat = c.value as? CheatTypeForMirror<Self>{
                    cheat.setOwner(self as! Self)
                }
            }
        }
    }
    
    public func crash(reason: Error){
        
        guard error == nil else{
            return
        }
        
        error = reason
        
    }
    
    
    @Message(Agent.onCrash) private var onCrashWrapper
    open func onCrash(_ error: Error){
        
    }
    
    @Message(Agent.upstreamAgentDidCrash) private var upstreamAgentDidCrashWrapper
    open func upstreamAgentDidCrash(tuple: (agent: Agent, reason: Error)){
        
    }
    
    
}


fileprivate struct CheatTypeForMirror<Owner : Agent>{
    
    let setOwner : (Owner) -> Void
    let getOwner : () -> Owner
    let getCrash : () -> Queued<Error?>
    let setCrash : (Error) -> Void
    
    init(){
        
        weak var owner : Owner?
        var crash : Queued<Error?>?
        
        self.setOwner = {crash = Queued(queue: $0.queue, nil); owner = $0}
        self.getOwner = {owner ?? {fatalError("Called a method of an actor that no longer exists. This is considered invalid and indicates a bad concurrency architecture.")}()}
        self.setCrash = {error in crash?.enqueueMutatingRead{$0 = error}}
        self.getCrash = {crash ?? {fatalError("Property wrapper \"Message\" can only be used on Agent.")}()}
        
    }
    
}


@propertyWrapper
public struct Message<Owner : Agent, T, U>{
    
    private let cheat = CheatTypeForMirror<Owner>()
    private let selector : (Owner) -> ((T) throws -> U)
    
    public var wrappedValue : PromiseArrow<T,U>{
        PromiseArrow{t in
            Promise<U>{handler in
                self.cheat.getCrash().enqueueRead{crash in
                    
                    if let crash = crash{
                        return handler(.failure(crash))
                    }
                    
                    let owner = self.cheat.getOwner()
                    
                    do{
                        handler(.success(try self.selector(owner)(t)))
                    }
                    catch{
                        handler(.failure(error))
                    }
                    
                }
            }
        }
    }
    
    public init(_ selector : @escaping (Owner) -> ((T) throws -> U)){
        self.selector = selector
    }
    
}
