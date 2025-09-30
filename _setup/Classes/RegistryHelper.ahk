class RegistryHelper {
    /**
     * Helper: Batch set registry values and create folders (flat or nested)
     * Accepts either:
     *   - Flat: [{path, name, value, ...}]
     *   - Nested: [{paths: [path1, path2], values: [{name, value, ...}]}]
     */
    static BatchSetRegistry(ops) {
        for _, op in ops {
            ; --- Nested  ---
            if op.HasProp("paths") && op.HasProp("values") {
                for _, regPath in op.paths {
                    for _, v in op.values {
                        if !v.HasProp("name") || !v.HasProp("value")
                            continue
                        type := v.HasProp("type") ? v.type : "REG_DWORD"
                        RegWrite(v.value, type, regPath, v.name)
                    }
                }
            }
            else if op.HasProp("path") && op.HasProp("name") && op.HasProp("value") {
                type := op.HasProp("type") ? op.type : "REG_DWORD"
                RegWrite(op.value, type, op.path, op.name)
            }
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
