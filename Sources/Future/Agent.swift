//
//  Actor.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



open class Agent{
    
    private var error : Error?{
        didSet{
            guard let reason = error else{
                return
            }
            
            var mirror : Mirror? = Mirror(reflecting: self)
            repeat{
                for child in mirror!.children{
                    let m = Mirror(reflecting: child.value)
                    for c in m.children{
                        if let cheat = c.value as? CheatTypeForMirror{
                            cheat.setCrash(reason)
                        }
                        if
                            let downstreamAgent = c.value as? Agent{
                            downstreamAgent.upstreamAgentDidCrashWrapper.send((agent: self, reason: reason))
                        }
                    }
                }
                mirror = mirror?.superclassMirror
            }while (mirror != nil)
            onCrashWrapper.send(reason)
        }
    }
    
    public init(){
        var mirror : Mirror? = Mirror(reflecting: self)
        repeat{
            for child in mirror!.children{
                let m = Mirror(reflecting: child.value)
                for c in m.children{
                    if let cheat = c.value as? CheatTypeForMirror{
                        cheat.setOwner(self as! Self)
                    }
                }
            }
            mirror = mirror?.superclassMirror
        }while (mirror != nil)
    }
    
    public func crash(reason: Error){
        
        guard error == nil else{
            return
        }
        
        error = reason
        
    }
    
    
    @Message(Agent.onCrash) public var onCrashWrapper
    open func onCrash(_ error: Error){
        
    }
    
    @Message(Agent.upstreamAgentDidCrash) public var upstreamAgentDidCrashWrapper
    open func upstreamAgentDidCrash(tuple: (agent: Agent, reason: Error)){
        
    }
    
    
}


fileprivate struct CheatTypeForMirror{
    
    let setOwner : (Agent) -> Void
    let getOwner : () -> Agent
    let getCrash : () -> AsyncRef<Error?>
    let setCrash : (Error) -> Void
    
    init(){
        
        weak var owner : Agent?
        var crash : AsyncRef<Error?>?
        
        self.setOwner = {crash = AsyncRef(nil); owner = $0}
        self.getOwner = {owner ?? {fatalError("Called a method of an actor that no longer exists. This is considered invalid and indicates a bad concurrency architecture.")}()}
        self.setCrash = {error in crash?.enqueueMutatingRead{$0 = error}}
        self.getCrash = {crash ?? {fatalError("Property wrapper \"Message\" can only be used on Agent.")}()}
        
    }
    
}


@propertyWrapper
public struct Message<Owner : Agent, T, U>{
    
    private let cheat = CheatTypeForMirror()
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
                        handler(.success(try self.selector(owner as! Owner)(t)))
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
