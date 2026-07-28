package evcore

import (
	"strings"
	"testing"
)

func TestStartCoreRejectsOtherEngines(t *testing.T) {
	err := StartCore("xray", "", 1, 1500)
	if err == nil || !strings.Contains(err.Error(), "unsupported core type") {
		t.Fatalf("expected unsupported core error, got %v", err)
	}
}

func TestStartCoreRejectsInvalidFileDescriptor(t *testing.T) {
	err := StartCore(CoreTypeMihomo, "", -1, 1500)
	if err == nil || err.Error() != "invalid tun file descriptor" {
		t.Fatalf("expected invalid file descriptor error, got %v", err)
	}
}
