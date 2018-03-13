/// <reference types="webpack-env" />
import { Definition } from "@stimulus/core";
export interface ECMAScriptModule {
    __esModule: boolean;
    default?: object;
}
export declare function definitionsFromContext(context: __WebpackModuleApi.RequireContext): Definition[];
export declare function identifierForContextKey(key: string): string | undefined;
