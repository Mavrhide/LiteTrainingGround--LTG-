<div align="center">

<img src="https://raw.githubusercontent.com/Mavrhide/LiteTrainingGround--LTG-/main/image/photo_2026-08-18_15-00-48.jpg" alt="LiteTrainingGround Banner" width="100%">

# 🎯 LITE TRAINING GROUND

### `[ e-commerce ]` → `[ bank ]` → `[ hospital ]` → `[ SOC видит всё ]`

<br>

![Status](https://img.shields.io/badge/STATUS-В%20РАЗРАБОТКЕ-orange?style=for-the-badge&labelColor=black)
![License](https://img.shields.io/badge/LICENSE-MIT-blue?style=for-the-badge&labelColor=black)
![Segments](https://img.shields.io/badge/СЕГМЕНТОВ-4-critical?style=for-the-badge&labelColor=black)
![Made in](https://img.shields.io/badge/MADE%20IN-DAGESTAN-green?style=for-the-badge&labelColor=black)

</div>

<br>

> Это не набор из десяти изолированных CTF-боксов, к каждому из которых прилагается отдельный вопрос "найди флаг".
> Это **одна живая сеть**. Точка входа — уязвимый интернет-магазин в DMZ. Дальше — твоя цепочка: закрепление, разведка внутренней сети, повышение привилегий, боковое движение через AD в банк и в больницу. Пока ты идёшь по цепочке — SOC-сегмент смотрит на тебя через Suricata и SIEM и считает, сколько твоих шагов он реально задетектил.

<br>

## 🧭 Как читать этот репозиторий

Каждая зона живёт в своей папке `segments/` и имеет **свой собственный README** — не нужно пролистывать один гигантский файл, чтобы найти нужный сегмент.

| | Зона | Что внутри | README зоны |
|---|---|---|---|
| 🛒 | **E-commerce (DMZ)** | WAF + уязвимый интернет-магазин техники | [`segments/ecommerce/README.md`](segments/ecommerce/README.md) |
| 🏦 | **Bank** | AD DC, core-banking БД, workstation оператора | [`segments/bank/README.md`](segments/bank/README.md) |
| 🏥 | **Hospital** | EHR/PACS-сервер, legacy-хост с медицинским ПО | [`segments/hospital/README.md`](segments/hospital/README.md) |
| 🛰 | **SOC** | Suricata NIDS + Wazuh/ELK, detection matrix | [`segments/soc/README.md`](segments/soc/README.md) |

Этот файл — только точка входа: архитектура целиком, модель угроз, как поднять полигон. За деталями конкретной зоны — идёшь в её README по ссылке выше.

<br>

## ⚔️ Прогресс

- [x] Архитектура сети и модель угроз
- [x] Сегментация: E-commerce / Bank / Hospital / SOC
- [x] Firewall (`nftables`)
- [x] E-commerce: WAF + уязвимый интернет-магазин
- [x] Bank: AD DC, core-banking БД, workstation оператора
- [x] Hospital: EHR/PACS-сервер, legacy-хост
- [ ] SOC: Suricata + Wazuh/ELK
- [ ] Автодеплой (Vagrant/Packer)
- [ ] Пошаговые сценарии атак (writeup'ы)
- [ ] Detection coverage matrix (MITRE ATT&CK)

Живой статус — во вкладке [Projects](../../projects).

<br>

## 🗺️ Архитектура

```
                              🌐 INTERNET
                                   │
                                   ▼
                        ┌───────────────────┐
                        │   WAF (HAProxy +   │
                        │    ModSecurity)     │
                        └─────────┬──────────┘
                                   │
                     🛒 E-COMMERCE │ 10.0.10.0/24
                     (точка входа) │  интернет-магазин техники
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │  КОРПОРАТИВНАЯ СЕТЬ (AD)   │
                    │      AD DS · AD CS         │
                    └────────────┬───────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 ▼                                ▼
      🏦 BANK  10.0.20.0/24              🏥 HOSPITAL  10.0.30.0/24
      core-banking БД                    EHR / PACS-сервер
      рабочая станция оператора          legacy-хост, устар. ПО

     ════════════════════════════════════════════════════
                    🛰 SOC · 10.0.40.0/24
        Suricata NIDS + Wazuh/ELK смотрят на ВСЁ выше
     ════════════════════════════════════════════════════
```

| Сегмент | Подсеть | Назначение |
|---|---|---|
| E-commerce (DMZ) | `10.0.10.0/24` | WAF-прокси, веб-приложение интернет-магазина |
| Bank | `10.0.20.0/24` | AD DC, core-banking БД, рабочая станция оператора |
| Hospital | `10.0.30.0/24` | EHR/PACS-сервер, legacy-хост, workstation мед. персонала |
| SOC | `10.0.40.0/24` | Suricata NIDS, SIEM, мониторинг всего периметра |

Полная модель угроз — в [`docs/architecture.md`](docs/architecture.md) *(скоро)*.

<br>

## 🎯 Зачем именно так

Три бизнес-домена — не для красоты, а потому что у каждого своя модель угроз и свой класс данных, которые в реальном мире защищают по-разному:

| Домен | Что защищает | Что тут отрабатывается |
|---|---|---|
| 🛒 E-commerce | Данные карт, заказы | SQLi, IDOR, обход WAF |
| 🏦 Bank | Финансовые операции, PCI DSS | AD-атаки, privesc, lateral movement |
| 🏥 Hospital | ПДн пациентов, мед. системы | Legacy-хосты, устаревшие протоколы, EternalBlue-класс |
| 🛰 SOC | Весь периметр | Detection engineering, разбор алертов, MITRE mapping |

Полигон устроен так, что взлом e-commerce — не отдельное упражнение, а **шаг 1** цепочки, которая ведёт через AD прямо в банк и в больницу.

<br>

## 🛠️ Стек

`nftables` · `Suricata` · `Wazuh / ELK` · `HAProxy + ModSecurity` · `Active Directory` · `PostgreSQL` · `Vagrant`

<br>

## 🚀 Быстрый старт

> ⚠️ Автодеплой ещё не готов — сборка сейчас частично ручная. Следи за прогрессом выше.

```bash
git clone https://github.com/Mavrhide/LiteTrainingGround--LTG-.git
cd LiteTrainingGround--LTG-
# дальше — по README нужного сегмента
```

<br>

## 🔗 Автор

<div align="center">

**[Mavrhide](https://github.com/Mavrhide)**

[Telegram](https://t.me/mavrhide) · [HackTheBox](https://profile.hackthebox.com/profile/019df95b-5a96-71ec-aa89-5a83d3e2b07c) · [TryHackMe](https://tryhackme.com/p/mavrhide)

📜 [PT EdTechLab — SIEM](https://github.com/Mavrhide/Certificates/blob/main/PT-EdTechLab-SIEM.pdf) · [PT EdTechLab — NTA](https://github.com/Mavrhide/Certificates/blob/main/PT-EdTechLab-NTA.pdf)

⭐ Если заходит идея — стар и ждать релиз. Разворачивать пока рано, но недолго осталось.

</div>
