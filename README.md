<div align="center">

<img src="https://raw.githubusercontent.com/Mavrhide/LiteTrainingGround--LTG-/main/image/photo_2026-08-18_15-00-48.jpg" alt="LiteTrainingGround Banner" width="100%">

# 🎯 LITE TRAINING GROUND

### `[ e-commerce ]` → `[ bank ]` → `[ hospital ]` — one kill chain, three business domains, one SOC watching it all

<br>

![Status](https://img.shields.io/badge/status-in%20development-orange?style=for-the-badge&logo=hackthebox&logoColor=white&labelColor=black)
![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge&logo=opensourceinitiative&logoColor=white&labelColor=black)
![Segments](https://img.shields.io/badge/segments-4-critical?style=for-the-badge&logo=hyperledger&logoColor=white&labelColor=black)
![Stack](https://img.shields.io/badge/stack-nftables%20%7C%20suricata%20%7C%20AD-informational?style=for-the-badge&logo=linux&logoColor=white&labelColor=black)

**[Explore the segments »](#-segments)** ·
**[Architecture](#%EF%B8%8F-architecture)** ·
**[Report a bug](../../issues)** ·
**[Request a feature](../../issues)** ·
**[Roadmap](../../projects)**

</div>

<br>

> [!NOTE]
> This repo is filling up in stages: architecture and firewall configs first, then vulnerable services per segment, then the SOC layer with attack scenarios and writeups. Star it now if you don't want to miss the release — but hold off on standing it up, there's no live lab yet.

<br>

## 📖 Table of Contents

<details>
<summary>Click to expand</summary>

- [The Idea](#-the-idea)
- [Progress](#-progress)
- [Architecture](#%EF%B8%8F-architecture)
- [Why It's Built This Way](#-why-its-built-this-way)
- [Segments](#-segments)
- [Tech Stack](#%EF%B8%8F-tech-stack)
- [Getting Started](#-getting-started)
- [Author](#-author)

</details>

<br>

## 💡 The Idea

**LiteTrainingGround** isn't a pile of isolated CTF boxes with a "find the flag" question bolted onto each one. It's **one connected infrastructure** spanning three business domains — e-commerce, bank, hospital — where every vulnerability is a step in a single attack chain: from the entry point in an online store, all the way to Domain Admin in the corporate network, and from there into patient/customer data — with a parallel breakdown of what the SOC actually manages to detect along the way.

```
Internet → WAF → Vulnerable electronics store (entry point)
                            │
                            ▼
                Shared corporate network (AD DS, AD CS)
                    │                       │
                    ▼                       ▼
             Bank segment              Hospital segment
        (core-banking DB,          (EHR/PACS, legacy hosts
         operator workstations)     with outdated software)

Everything above is watched by Suricata NIDS + SIEM, sitting in an isolated SOC segment
```

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## ⚔️ Progress

- [x] Network architecture & threat model
- [x] Segmentation: E-commerce / Bank / Hospital / SOC
- [x] Firewall config (`nftables`)
- [x] E-commerce: WAF + vulnerable electronics store
- [x] Bank: AD DC, core-banking DB, operator workstation
- [x] Hospital: EHR/PACS server, legacy host
- [ ] SOC: Suricata + Wazuh/ELK
- [ ] Auto-deploy scripts (Vagrant/Packer)
- [ ] Step-by-step attack scenarios with writeups
- [ ] Detection coverage matrix (MITRE ATT&CK)

Live status lives in the [Projects](../../projects) tab.

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## 🗺️ Architecture

```
                              🌐 INTERNET
                                   │
                                   ▼
                        ┌───────────────────┐
                        │   WAF (HAProxy +    │
                        │    ModSecurity)      │
                        └─────────┬───────────┘
                                   │
                     🛒 E-COMMERCE │ 10.0.10.0/24
                     (entry point) │  electronics store
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │   CORPORATE NETWORK (AD)   │
                    │      AD DS · AD CS          │
                    └────────────┬────────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 ▼                                ▼
      🏦 BANK  10.0.20.0/24              🏥 HOSPITAL  10.0.30.0/24
      core-banking DB                    EHR / PACS server
      operator workstation               legacy host, old software

     ════════════════════════════════════════════════════
                    🛰 SOC · 10.0.40.0/24
        Suricata NIDS + Wazuh/ELK watching everything above
     ════════════════════════════════════════════════════
```

| Segment | Subnet | Purpose |
|---|---|---|
| E-commerce (DMZ) | `10.0.10.0/24` | WAF proxy, electronics store web app |
| Bank | `10.0.20.0/24` | AD DC, core-banking DB, operator workstation |
| Hospital | `10.0.30.0/24` | EHR/PACS server, legacy host, staff workstation |
| SOC | `10.0.40.0/24` | Suricata NIDS, SIEM, full-perimeter monitoring |

Full threat model: [`docs/architecture.md`](docs/architecture.md) *(coming soon)*.

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## 🎯 Why It's Built This Way

Three business domains aren't there for decoration — each one carries a different threat model and a different class of data to protect, the same way it works in the real world:

| Domain | Protects | Trained here |
|---|---|---|
| 🛒 E-commerce | Card data, orders | SQLi, IDOR, WAF bypass |
| 🏦 Bank | Financial transactions, PCI DSS | AD attacks, privilege escalation, lateral movement |
| 🏥 Hospital | Patient PII, medical systems | Legacy hosts, outdated protocols, EternalBlue-class bugs |
| 🛰 SOC | The entire perimeter | Detection engineering, alert triage, MITRE mapping |

The lab is wired so that popping the e-commerce store isn't a standalone exercise — it's **step one** of a chain that runs through AD straight into the bank and the hospital.

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## 🧭 Segments

Each zone lives in its own folder under `segments/` and ships its **own README** — no need to scroll one giant file to find what you're after.

| | Segment | What's inside | Segment README |
|---|---|---|---|
| 🛒 | **E-commerce (DMZ)** | WAF + vulnerable electronics store | [`segments/ecommerce/README.md`](segments/ecommerce/README.md) |
| 🏦 | **Bank** | AD DC, core-banking DB, operator workstation | [`segments/bank/README.md`](segments/bank/README.md) |
| 🏥 | **Hospital** | EHR/PACS server, legacy host | [`segments/hospital/README.md`](segments/hospital/README.md) |
| 🛰 | **SOC** | Suricata NIDS + Wazuh/ELK, detection matrix | [`segments/soc/README.md`](segments/soc/README.md) |

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## 🛠️ Tech Stack

![nftables](https://img.shields.io/badge/nftables-000000?style=flat-square&logo=linux&logoColor=white)
![Suricata](https://img.shields.io/badge/Suricata-CC0000?style=flat-square&logo=suricata&logoColor=white)
![Wazuh](https://img.shields.io/badge/Wazuh%2FELK-005571?style=flat-square&logo=elastic&logoColor=white)
![HAProxy](https://img.shields.io/badge/HAProxy%20%2B%20ModSecurity-106DA9?style=flat-square&logo=haproxy&logoColor=white)
![AD](https://img.shields.io/badge/Active%20Directory-0078D4?style=flat-square&logo=windows&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![Vagrant](https://img.shields.io/badge/Vagrant-1868F2?style=flat-square&logo=vagrant&logoColor=white)

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## 🚀 Getting Started

> [!WARNING]
> Auto-deploy isn't ready yet — spin-up is still partly manual. Watch the progress checklist above for updates.

### Prerequisites

- Vagrant + a hypervisor (VirtualBox/libvirt)
- ~16 GB RAM free for the full four-segment lab
- Basic familiarity with `nftables` and Active Directory

### Clone

```bash
git clone https://github.com/Mavrhide/LiteTrainingGround--LTG-.git
cd LiteTrainingGround--LTG-
```

From here, follow the README inside the segment you want to attack first.

<sub>[⬆ back to top](#-lite-training-ground)</sub>

<br>

## 👤 Author

<div align="center">

**[Mavrhide](https://github.com/Mavrhide)**

[Telegram](https://t.me/mavrhide) · [HackTheBox](https://profile.hackthebox.com/profile/019df95b-5a96-71ec-aa89-5a83d3e2b07c) · [TryHackMe](https://tryhackme.com/p/mavrhide)

📜 [PT EdTechLab — SIEM](https://github.com/Mavrhide/Certificates/blob/main/PT-EdTechLab-SIEM.pdf) · [PT EdTechLab — NTA](https://github.com/Mavrhide/Certificates/blob/main/PT-EdTechLab-NTA.pdf)

⭐ **Star it if the idea's interesting — the live lab isn't far off.**

<sub>[⬆ back to top](#-lite-training-ground)</sub>

</div>
