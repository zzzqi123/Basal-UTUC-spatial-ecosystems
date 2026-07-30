# Data access

No patient-level or large binary data are stored in this repository.

Create the following local directories after obtaining the relevant approvals
and public datasets:

```text
data/
├── private/       institutional and controlled-access inputs
├── public/        downloaded public datasets
└── processed/     local analysis-ready objects
```

Expected file names and accessions are defined in
[`../manifests/data_manifest.tsv`](../manifests/data_manifest.tsv).

The code validates schemas and sample identifiers but does not attempt to
download controlled-access data. Never commit the three directories above.

