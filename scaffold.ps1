# Scaffold script for LiteTrainingGround (LTG) directory structure — PowerShell version.
# Usage:
#   cd C:\path\to\LiteTrainingGround--LTG-
#   powershell -ExecutionPolicy Bypass -File .\scaffold.ps1

$dirs = @(
  ".github/workflows",
  "docs/attack-scenarios",
  "image",
  "firewall/nftables/segments",
  "segments/ecommerce/waf",
  "segments/ecommerce/app",
  "segments/bank/ad-dc",
  "segments/bank/core-banking-db",
  "segments/bank/operator-workstation",
  "segments/hospital/ehr-pacs",
  "segments/hospital/legacy-host",
  "segments/soc/suricata/rules",
  "segments/soc/wazuh-elk/config",
  "infra/vagrant",
  "infra/packer/templates",
  "infra/provisioning/scripts",
  "scripts"
)

$files = @(
  "docs/architecture.md",
  "docs/network-diagram.md",
  "docs/detection-coverage-matrix.md",
  "docs/attack-scenarios/01-ecommerce-foothold.md",
  "docs/attack-scenarios/02-corporate-pivot.md",
  "docs/attack-scenarios/03-bank-domain-admin.md",
  "docs/attack-scenarios/04-hospital-legacy-rce.md",
  "firewall/nftables/router.nft",
  "firewall/nftables/segments/ecommerce.nft",
  "firewall/nftables/segments/bank.nft",
  "firewall/nftables/segments/hospital.nft",
  "firewall/nftables/segments/soc.nft",
  "infra/vagrant/Vagrantfile",
  "scripts/deploy.sh",
  "scripts/teardown.sh",
  "scripts/healthcheck.sh",
  ".github/workflows/lint.yml",
  "CHANGELOG.md"
)

foreach ($d in $dirs) {
  New-Item -ItemType Directory -Force -Path $d | Out-Null
  # keep otherwise-empty dirs tracked by git
  New-Item -ItemType File -Force -Path (Join-Path $d ".gitkeep") | Out-Null
}

foreach ($f in $files) {
  if (-not (Test-Path $f)) {
    $name = Split-Path $f -Leaf
    Set-Content -Path $f -Value "# TODO: $name"
  }
}

Write-Host "Scaffold created. Review, then:"
Write-Host "  git add ."
Write-Host "  git commit -m 'Scaffold project directory structure'"
Write-Host "  git push"
