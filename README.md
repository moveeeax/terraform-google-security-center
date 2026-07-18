# terraform-google-security-center

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
Security Command Center source (`google_scc_source`). A source is the container
under which an integration reports security findings for an organization.

## Usage

```hcl
module "security_center" {
  source = "github.com/cybercapybara/terraform-google-security-center"

  organization = "123456789012"
  display_name = "custom-scanner"
  description  = "Findings from the custom scanner"
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| google    | >= 5.0   |

## Inputs

| Name           | Description                                              | Type     | Default                  | Required |
|----------------|----------------------------------------------------------|----------|--------------------------|:--------:|
| `organization` | Numeric organization id that owns the source.            | `string` | n/a                      |   yes    |
| `display_name` | Display name of the source.                              | `string` | n/a                      |   yes    |
| `description`  | Description of the source.                               | `string` | `"Managed by Terraform"` |    no    |

## Outputs

| Name   | Description                                       |
|--------|---------------------------------------------------|
| `id`   | Identifier of the source.                        |
| `name` | Resource name of the source.                     |

## License

[MIT](LICENSE)
