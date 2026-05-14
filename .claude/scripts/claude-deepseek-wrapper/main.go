package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func main() {
	// 1. Resolve exe location
	exePath, err := os.Executable()
	if err != nil {
		fmt.Fprintln(os.Stderr, "[wrapper] Cannot resolve exe path:", err)
		os.Exit(1)
	}
	exeDir    := filepath.Dir(exePath)
	claudeRoot := filepath.Dir(exeDir)

	// 2. Load token from <claudeRoot>\.deepseek-token
	tokenPath  := filepath.Join(claudeRoot, ".deepseek-token")
	tokenBytes, err := os.ReadFile(tokenPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "[wrapper] Token file '.deepseek-token' not found:", tokenPath)
		os.Exit(1)
	}
	token := strings.TrimSpace(string(tokenBytes))
	if token == "" {
		fmt.Fprintln(os.Stderr, "[wrapper] Token file '.deepseek-token' is empty:", tokenPath)
		os.Exit(1)
	}

	// 3. Inject environment variables (inherited by child)
	os.Setenv("ANTHROPIC_AUTH_TOKEN",            token)
	os.Setenv("ANTHROPIC_BASE_URL",              "https://api.deepseek.com/anthropic")
	os.Setenv("ANTHROPIC_MODEL",                 "deepseek-v4-flash")
	os.Setenv("ANTHROPIC_DEFAULT_OPUS_MODEL",    "deepseek-v4-pro[1m]")
	os.Setenv("ANTHROPIC_DEFAULT_SONNET_MODEL",  "deepseek-v4-pro[1m]")
	os.Setenv("ANTHROPIC_DEFAULT_HAIKU_MODEL",   "deepseek-v4-flash")
	os.Setenv("CLAUDE_CODE_SUBAGENT_MODEL",      "deepseek-v4-flash")
	os.Setenv("CLAUDE_CODE_EFFORT_LEVEL",        "max")

	// 4. Forward to claude — VS Code calls: <wrapper.exe> claude [args…]
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "[wrapper] No target supplied. Expected: wrapper.exe claude [args…]")
		os.Exit(1)
	}

	cmd := exec.Command(os.Args[1], os.Args[2:]...)
	cmd.Stdin  = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			os.Exit(exitErr.ExitCode())
		}
		fmt.Fprintln(os.Stderr, "[wrapper] Failed to run claude:", err)
		os.Exit(1)
	}
}
