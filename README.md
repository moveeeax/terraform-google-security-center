# terraform-google-security-center

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
Security Command Center source (`google_scc_source`), together with the IAM
bindings that let an integration actually report findings into it.

A source is the container under which an integration reports security findings
for an organization. Creating the source grants nobody permission to write into
it: unless the reporting identity holds `roles/securitycenter.findingsEditor`
on the source (or inherits an equivalent role from the organization), every
`createFinding` call is denied and the source stays permanently empty. Set
`findings_editors` so that does not happen.

## Usage

```hcl
module "security_center" {
  source = "github.com/moveeeax/terraform-google-security-center"

  organization = "123456789012"
  display_name = "custom-scanner"
  description  = "Findings from the custom scanner"

  # The identity that writes findings into this source.
  findings_editors = [
    "serviceAccount:custom-scanner@example.iam.gserviceaccount.com",
  ]

  # The people who read them.
  findings_viewers = [
    "group:secops@example.com",
  ]
}
```

A runnable example lives in [`examples/basic`](examples/basic).

`organization` is the bare numeric organization id. Passing a resource path
such as `organizations/123456789012` is rejected by variable validation,
because the provider interpolates the value into
`organizations/<organization>/sources` and would otherwise build a malformed
API path.

`allUsers` and `allAuthenticatedUsers` are rejected in both IAM lists: security
findings must not be world-readable, and nobody should be able to inject
findings anonymously.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| google    | >= 5.0   |

The test suite under [`tests/`](tests) additionally needs Terraform (or
OpenTofu) >= 1.7 for `mock_provider`. That is a test-only requirement; the
module itself still supports >= 1.5.

## Inputs

| Name               | Description                                                                     | Type           | Default                  | Required |
|--------------------|---------------------------------------------------------------------------------|----------------|--------------------------|:--------:|
| `organization`     | Bare numeric organization id that owns the source.                              | `string`       | n/a                      |   yes    |
| `display_name`     | Display name of the source (1-64 characters, unique within the organization).   | `string`       | n/a                      |   yes    |
| `description`      | Description of the source (max 1024 characters).                                | `string`       | `"Managed by Terraform"` |    no    |
| `findings_editors` | Principals granted `roles/securitycenter.findingsEditor` **on this source**.    | `list(string)` | `[]`                     |    no    |
| `findings_viewers` | Principals granted `roles/securitycenter.findingsViewer` **on this source**.    | `list(string)` | `[]`                     |    no    |

## Outputs

| Name   | Description                                                            |
|--------|------------------------------------------------------------------------|
| `id`   | Identifier of the source.                                              |
| `name` | Resource name of the source, `organizations/<org>/sources/<id>`.       |

## Development

```sh
terraform fmt -check -recursive
terraform init -backend=false && terraform validate
terraform test
```

`terraform test` uses `mock_provider`, so it needs no credentials and makes no
API calls. It runs in CI on every pull request.

## License

[MIT](LICENSE)
