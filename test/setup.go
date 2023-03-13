package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// SetupStep will run any setup tfg required prior to running tests
// returns an error in which case tests should fail immediately
// tf destroy is run inside the error so should do any clean up
func SetupStep(t *testing.T, opts *terraform.Options) (func(), error) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, opts)

	if _, err := terraform.InitAndApplyE(t, terraformOptions); err != nil {
		terraform.Destroy(t, terraformOptions)
		t.Errorf("failed to set up: %v", err)
		return nil, err
	}

	return func() { terraform.Destroy(t, terraformOptions) }, nil
}

// DoInitApplyE creates a workspace selects it
// runs apply in that workspace and returns a deferable
// destroy and delete workspace
func DoInitApplyE(t *testing.T, opts *terraform.Options, wsname string) (func(), error) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, opts)
	// Init
	if _, err := terraform.InitE(t, terraformOptions); err != nil {
		t.Fatalf("failed to init: %v", err)
	}

	// relies on consistently named backend files
	// crude but ...
	_ = os.Rename(filepath.Join(opts.TerraformDir, "backend.tf"), filepath.Join(opts.TerraformDir, "backend.__tf__"))

	// select/create new workspace
	if _, err := terraform.WorkspaceSelectOrNewE(t, terraformOptions, wsname); err != nil {
		t.Fatalf("failed to create workspace: %v", err)
	}

	if _, err := terraform.ApplyE(t, opts); err != nil {
		// t.Errorf("failed to apply: %v", err)
		// terraform.Destroy(t, opts)
		return CleanUp(t, opts, wsname), err
	}

	return CleanUp(t, opts, wsname), nil
}

// CleanUp returns deferable funcs to clean stuff up
func CleanUp(t *testing.T, opts *terraform.Options, wsname string) func() {
	return func() {
		terraform.WorkspaceSelectOrNew(t, opts, wsname)
		terraform.Destroy(t, opts)
		terraform.WorkspaceSelectOrNew(t, opts, "default")
		terraform.WorkspaceDelete(t, opts, wsname)
		// revert backend.tf
		_ = os.Rename(filepath.Join(opts.TerraformDir, "backend.__tf__"), filepath.Join(opts.TerraformDir, "backend.tf"))
	}
}

// TODO: add func to search
// implementation folder for a backend bloc {} and change it to local for test duration
// func DisableBackend()  {

// }
