class RegistryHelper {
    /**
     * Helper: Batch set registry values and create folders (flat or nested)
     * Accepts:
     *   - Nested with multiple paths: {paths: [path1, path2], values: [{name, value, ...}, ...]}
     *   - Nested with single path: {path: "path", values: [{name, value, ...}, ...]}
     *   - Flat with multiple paths: {paths: [path1, path2], value: {name, value, ...}}
     *   - Flat with single path: {path: "path", value: {name, value, ...}}
     */
    static BatchSetRegistry(ops) {
        for _, op in ops {
            try {
                ; Collect all paths (from either "path" or "paths")
                regPaths := []
                if op.HasProp("paths") && IsObject(op.paths) {
                    for _, p in op.paths
                        regPaths.Push(p)
                }
                else if op.HasProp("path") {
                    regPaths.Push(op.path)
                }

                ; Collect all values (from either "value" or "values")
                regValues := []
                if op.HasProp("values") && IsObject(op.values) {
                    for _, v in op.values
                        regValues.Push(v)
                }
                else if op.HasProp("value") && IsObject(op.value) {
                    regValues.Push(op.value)
                }

                ; Validate we have both paths and values
                if regPaths.Length = 0 || regValues.Length = 0 {
                    continue
                }

                for _, regPath in regPaths {
                    for _, v in regValues {
                        if !v.HasProp("name") || !v.HasProp("value")
                            continue

                        type := v.HasProp("type") ? v.type : this.GetRegType(v.value)
                        RegWrite(v.value, type, regPath, v.name)
                    }
                }
            }
            catch Error as e {
                OutputDebug("Error setting registry value: " e.Message)
            }
        }
    }

    /**
     * Convert registry value to appropriate type
     */
    static GetRegType(value) {
        if (value is String) {
            return "REG_SZ"
        }
        else if (value is Number) {
            return "REG_DWORD"
        }
        else {
            throw Error("Unsupported registry value type.")
        }
    }

    ; Method to check if a registry key exists
    static KeyExists(KeyName) {
        try {
            split := StrSplit(KeyName, "\")
            KeyName := StrReplace(KeyName, split[split.Length], "", 1)
            Loop Reg, KeyName, "K"
            {
                if (A_LoopRegName = split[split.Length])
                    return true
            }
            return false
        } catch as e {
            MsgBox "Error checking if registry key exists: " e.message
            return false
        }
    }

    ; Method to check if a registry value exists
    static ValueExists(KeyName, ValueName) {
        try {
            Loop Reg, KeyName, "V"
            {
                if (A_LoopRegName = ValueName)
                    return true
            }
            return false
        } catch as e {
            MsgBox "Error checking if registry value exists: " e.message
            return false
        }
    }
}
