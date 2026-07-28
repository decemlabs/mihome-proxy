// Package evcore is the gomobile bridge between Mihome Proxy's Network
// Extension and Mihomo. It owns one Mihomo instance backed by the utun file
// descriptor supplied by NEPacketTunnelProvider.
package evcore

import (
	"errors"
	"fmt"
	"sync"
)

const CoreTypeMihomo = "mihomo"

var (
	mu           sync.Mutex
	coreInstance coreRunner
)

type coreRunner interface {
	stop() error
	suspend()
	resume()
	updateDefaultInterface(name string, index int32, isExpensive, isConstrained bool)
}

func Version() string { return "Mihome Core v1" }

// StartCore retains the bridge signature used by Mihome Proxy, but this
// package contains and starts only Mihomo.
func StartCore(coreType, configContent string, tunFD, mtu int) error {
	mu.Lock()
	defer mu.Unlock()

	if coreInstance != nil {
		return errors.New("a core is already running")
	}
	if coreType != CoreTypeMihomo {
		return fmt.Errorf("unsupported core type: %s", coreType)
	}
	if tunFD < 0 {
		return errors.New("invalid tun file descriptor")
	}
	if mtu <= 0 {
		mtu = 1500
	}

	runner, err := startMihomo(configContent, tunFD, mtu)
	if err != nil {
		// gomobile cannot safely box errors whose concrete value contains
		// non-comparable fields. Flatten every upstream error to errorString.
		return errors.New(err.Error())
	}
	coreInstance = runner
	return nil
}

func Suspend() error {
	mu.Lock()
	defer mu.Unlock()
	if coreInstance != nil {
		coreInstance.suspend()
	}
	return nil
}

func Resume() error {
	mu.Lock()
	defer mu.Unlock()
	if coreInstance != nil {
		coreInstance.resume()
	}
	return nil
}

func UpdateDefaultInterface(name string, index int32, isExpensive, isConstrained bool) error {
	mu.Lock()
	defer mu.Unlock()
	if coreInstance != nil {
		coreInstance.updateDefaultInterface(name, index, isExpensive, isConstrained)
	}
	return nil
}

// StopAll keeps the original exported name used by Swift. Mihomo shutdown is
// detached because iOS gives Packet Tunnel extensions little teardown time.
func StopAll() error {
	mu.Lock()
	previous := coreInstance
	coreInstance = nil
	mu.Unlock()

	go func() {
		defer func() { _ = recover() }()
		if previous != nil {
			_ = previous.stop()
		}
	}()
	return nil
}
