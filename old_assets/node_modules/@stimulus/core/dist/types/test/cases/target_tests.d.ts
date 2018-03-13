import { TargetControllerTestCase } from "../target_controller_test_case";
export default class TargetTests extends TargetControllerTestCase {
    fixtureHTML: string;
    "test TargetSet#find"(): void;
    "test TargetSet#findAll"(): void;
    "test TargetSet#findAll with multiple arguments"(): void;
    "test TargetSet#has"(): void;
    "test TargetSet#find ignores child controller targets"(): void;
    "test linked target properties"(): void;
    "test inherited linked target properties"(): void;
    "test singular linked target property throws an error when no target is found"(): void;
    "test has*Target property names are not localized"(): void;
}
