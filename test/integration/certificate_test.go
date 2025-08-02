package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAzureCertificateManagement(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"key_vault_name":      "test-cert-vault",
			"location":            "eastus",
			"resource_group_name": "test-rg",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Key Vault exists
	keyVaultName := terraform.Output(t, terraformOptions, "key_vault_name")
	assert.NotEmpty(t, keyVaultName)

	// Verify self-signed certificate was created
	certificateId := terraform.Output(t, terraformOptions, "self_signed_certificate_id")
	assert.NotEmpty(t, certificateId)
}
