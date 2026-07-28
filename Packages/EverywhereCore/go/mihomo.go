package evcore

import (
	"errors"
	"syscall"

	"github.com/metacubex/mihomo/component/iface"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/tunnel"
)

type mihomoRunner struct{}

func (m *mihomoRunner) stop() error {
	executor.Shutdown()
	return nil
}

func (m *mihomoRunner) suspend() {
	tunnel.OnSuspend()
}

func (m *mihomoRunner) resume() {
	tunnel.OnRunning()
}

func (m *mihomoRunner) updateDefaultInterface(_ string, _ int32, _, _ bool) {
	iface.FlushCache()
	resolver.ResetConnection()
}

// startMihomo parses the YAML, injects a duplicate of the Packet Tunnel file
// descriptor, and applies the configuration including the controller API.
func startMihomo(configContent string, tunFD, _ int) (coreRunner, error) {
	cfg, err := executor.ParseWithBytes([]byte(configContent))
	if err != nil {
		return nil, err
	}
	if cfg.General == nil {
		return nil, errors.New("mihomo: parsed config has no general block")
	}
	if !cfg.General.Tun.Enable {
		return nil, errors.New("mihomo: tun block is missing or disabled")
	}

	dupFD, err := syscall.Dup(tunFD)
	if err != nil {
		return nil, err
	}
	cfg.General.Tun.FileDescriptor = dupFD

	if cfg.DNS == nil || !cfg.DNS.Enable {
		cfg.General.Tun.DNSHijack = nil
	}

	hub.ApplyConfig(cfg)
	return &mihomoRunner{}, nil
}
