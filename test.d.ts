export abstract class A {
    foo(): void;
    get_style (): number;
    public abstract connect(sigName: "desktop_folder", callback: ((obj: A, ) =>  void )): number;
    public abstract connect_after(sigName: "desktop_folder", callback: ((obj: A, ) =>  void )): number;
    public abstract emit(sigName: "desktop_folder", ): void;
}

export abstract class B {
    bar(): boolean;
    get_style (): string;
    public abstract connect(sigName: "test", callback: ((obj: B, ) =>  void )): number;
    public abstract connect_after(sigName: "test", callback: ((obj: B, ) =>  void )): number;
    public abstract emit(sigName: "test", ): void;
}

interface C extends A, B {
    get_style (): number | string;
    connect(sigName: "desktop_folder", callback: ((obj: A, ) =>  void )): number;
    connect_after(sigName: "desktop_folder", callback: ((obj: A, ) =>  void )): number;
    emit(sigName: "desktop_folder", ): void;
    connect(sigName: "test", callback: ((obj: B, ) =>  void )): number;
    connect_after(sigName: "test", callback: ((obj: B, ) =>  void )): number;
    emit(sigName: "test", ): void;
}


export class C implements A, B {
    bar(): boolean;
}

