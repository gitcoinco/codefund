export declare class Multimap<K, V> {
    private valuesByKey;
    constructor();
    readonly values: V[];
    readonly size: number;
    add(key: K, value: V): void;
    delete(key: K, value: V): void;
    has(key: K, value: V): boolean;
    hasKey(key: K): boolean;
    hasValue(value: V): boolean;
    getValuesForKey(key: K): V[];
    getKeysForValue(value: V): K[];
}
