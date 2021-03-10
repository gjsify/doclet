export class A {
    foo(): void;
}

export class B {
    bar(): boolean;
}

interface C extends A, B {}


export class C implements A, B {
    bar(): boolean;
}