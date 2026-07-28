package evcore

import (
	"errors"
	"os"

	mihomoConstant "github.com/metacubex/mihomo/constant"
)

// SetResourcesPath makes the App Group Resources directory Mihomo's home.
func SetResourcesPath(path string) error {
	if path == "" {
		return errors.New("empty resources path")
	}
	if err := os.MkdirAll(path, 0o755); err != nil {
		return err
	}
	mihomoConstant.SetHomeDir(path)
	return nil
}
