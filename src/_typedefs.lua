------------------------------------------------------------------------
-- _typedefs.lua
-- @version 1.0.0
------------------------------------------------------------------------
export type table = {[any]: any}
export type Array<T> = {[number]: T}
export type Map<T, U> = {[T]: U}
------------------------------------
-- Complex v1.0.0
------------------------------------
export type Complex = typeof(setmetatable(
    {} :: {
        X: number;
        Y: number;
        Magnitude: (Complex) -> number;
        AbsSquare: (Complex) -> number;
        Conjugate: (Complex) -> Complex;
        ToPolar: (Complex) -> (number, number);
        Orbit: (Complex, c: Complex, maxIter: number, escapeOrbit: number?) -> number;
    }, {} :: {
        __add: (Complex, Complex) -> Complex;
        __sub: (Complex, Complex) -> Complex;
        __mul: (Complex, Complex) -> Complex;
        __div: (Complex, Complex) -> Complex;
        __pow: (Complex, Complex) -> Complex;
        __unm: (Complex) -> Complex;
        __eq: (Complex, Complex) -> Complex;
        __tostring: (Complex) -> string;
    }
))
------------------------------------
-- Queue v1.0.0
------------------------------------
export type Queue<T> = {
    Push: (Queue<T>, T) -> ();
    Pop: (Queue<T>) -> T;
    GetFirst: (Queue<T>) -> T;
    GetLast: (Queue<T>) -> T;
    Size: (Queue<T>) -> number;
}
------------------------------------
-- RDLScriptSignal v1.0.0
------------------------------------
export type RDLScriptConnection = {
    IsConnected: (RDLScriptConnection) -> boolean;
    Disconnect: (RDLScriptConnection) -> ();
}

export type RDLScriptSignal<T...> = {
    Connect: (RDLScriptSignal<T...>, callback: (T...) -> ()) -> RDLScriptConnection;
    Wait: (RDLScriptSignal<T...>) -> T...;
    Fire: (RDLScriptSignal<T...>, T...) -> ();
    DisconnectAll: (RDLScriptSignal<T...>) -> ();
}
------------------------------------
-- Hitbox v1.0.0
------------------------------------
export type Hitbox = {
    RaycastParams: RaycastParams;
    Debug: boolean;
    Hit: RDLScriptSignal<RaycastResult>;

    Start: (Hitbox) -> ();
    Stop: (Hitbox) -> ();
}
------------------------------------
-- Caster v1.0.0
------------------------------------
export type Caster = {
    Acceleration: Vector3;
    RaycastParams: RaycastParams?;
    CanPierce: (id: Cast, hit: RaycastResult) -> boolean;

    Stepped: (id: Cast, dt: number) -> ();
    Pierced: (id: Cast, hit: RaycastResult) -> ();
    Hit: (id: Cast, hit: RaycastResult) -> ();
    Terminating: (id: Cast) -> ();

    Fire: (Caster, origin: Vector3, velocity: Vector3) -> Cast;
    CloneRaycastParams: (Caster) -> RaycastParams;
    Terminate: (Caster, id: Cast) -> ();
}
------------------------------------
-- Cast v1.0.0
------------------------------------
export type Cast = number
------------------------------------
-- Fabrik v0.0.0
------------------------------------
--[[ (Constraint for P2 to P3, looking from P1 to P2) ]]
export type IKConstraint = Array<number>

export type Fabrik = {
    JointPositions: Array<Vector3>;
    SegmentLengths: Array<number>;
    JointConstraints: Array<IKConstraint|nil>;

    AddSegment: (Fabrik, length: number, jointConstraints: IKConstraint?) -> Fabrik;

    BackwardSolve: (Fabrik, target: Vector3) -> ();
    ForwardSolve: (Fabrik, origin: Vector3) -> ();
    Solve: (Fabrik, origin: Vector3, target: Vector3) -> ();

    ForwardConstrainedSolve: (Fabrik, originCF: CFrame) -> ();
    ConstrainedSolve: (Fabrik, originCF: CFrame, target: Vector3) -> ();

    Reset: (Fabrik) -> ();

    GetJointPositions: (Fabrik) -> Array<Vector3>;
    GetJointCFrames: (Fabrik) -> Array<CFrame>;
    GetJointRelativeCFrames: (Fabrik) -> Array<CFrame>;
    GetSegmentCFrames: (Fabrik) -> Array<CFrame>;
}
------------------------------------
-- Quick v0.0.0
------------------------------------
export type UIState = {
    [number|string]: any;
}
------------------------------------
-- bt v0.0.0
------------------------------------
export type BehaviourTree = {
    
}
------------------------------------
--
------------------------------------
return nil