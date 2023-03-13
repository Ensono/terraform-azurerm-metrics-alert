package test

import (
	"fmt"
	"math/rand"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Vars(namer string) (map[string]any, func()) {

	vars := map[string]any{}
	vars["name"] = namer
	return vars, func() {
		for k := range vars {
			delete(vars, k)
		}
	}
}

func genRandomStr(seededRand *rand.Rand) string {
	charset := []byte("abcdefghijklmnopqrstuvwxyz")
	randStr := make([]byte, 6)
	for i := range randStr {
		// randomly select 1 character from given charset
		randStr[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(randStr)
}

func TestMetricAlertsAzure_TF_0_14(t *testing.T) {
	ttests := map[string]struct {
		randSeeder *rand.Rand
		tfDir      string
		wsname     string
		// setupVars  func(t *testing.T) (map[string]string, func())
	}{
		"full alert with 2 services with action group": {
			rand.New(rand.NewSource(time.Now().UnixNano())),
			"../examples/full",
			fmt.Sprintf("test-ws-%d", time.Now().UnixNano()),
		},
		"alerts only no action group": {
			rand.New(rand.NewSource(time.Now().UnixNano())),
			"../examples/noalert",
			fmt.Sprintf("test-ws-%d", time.Now().UnixNano()),
		},
		"one alert with action group": {
			rand.New(rand.NewSource(time.Now().UnixNano())),
			"../examples/one-serviceq-alert",
			fmt.Sprintf("test-ws-%d", time.Now().UnixNano()),
		},
	}
	for name, tt := range ttests {
		t.Run(name, func(t *testing.T) {

			vars, clearVars := Vars(genRandomStr(tt.randSeeder))
			defer clearVars()

			tfOpts := &terraform.Options{
				TerraformDir: tt.tfDir,
				Vars:         vars,
				// BackendConfig: map[string]any{},
			}

			if tfbin, ok := os.LookupEnv("TEST_TF_BIN"); ok {
				tfOpts.TerraformBinary = tfbin
			}

			cleanUp, err := DoInitApplyE(t, tfOpts, tt.wsname)

			defer cleanUp()

			if err != nil {
				t.Errorf("err: %v", err)
			}
			// start assertions
			output := terraform.Output(t, tfOpts, "monitor_metric_alert")
			assert.NotNil(t, output)
			assert.Contains(t, output, "")

		})
	}
}
