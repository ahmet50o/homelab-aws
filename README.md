# Homelab auf AWS

Lernprojekt, mit dem ich mir DevOps und Infrastruktur beibringe. Ich baue eine kleine
Umgebung auf AWS auf, wie man sie in einer Firma finden könnte: getrennte Netze, eigene
Zertifikate, zentrale Anmeldung, GitLab und am Ende ein Kubernetes-Cluster.

Alles wird mit Terraform und Ansible aufgebaut, nichts per Hand in der AWS-Konsole.

## Stand

Das Projekt ist nicht fertig.

| Phase | Inhalt | Stand |
|---|---|---|
| 0 | AWS-Konto, S3-Backend, Key Pair | fertig |
| 1 | Netz und VMs mit Terraform | fertig |
| 2 | Dienste mit Ansible | geschrieben, läuft durch, noch nicht richtig geprüft |
| 3 | Kubernetes (kubeadm, Cilium) | Rollen geschrieben, noch nicht geprüft |
| 4 | GitLab CI, ArgoCD | offen |
| 5 | Prometheus, Grafana, Loki | offen |
| 6 | Eine kleine App, die darauf läuft | offen |

Was "noch nicht richtig geprüft" heißt: Die VMs starten, und `site.yml` läuft ohne Fehler
durch. Ob jeder Dienst danach wirklich so arbeitet wie gedacht, habe ich noch nicht
systematisch getestet. Das ist der nächste Schritt.

Die Umgebung läuft nicht dauerhaft. 13 VMs kosten Geld, deshalb fahre ich sie nur hoch,
wenn ich daran arbeite.

## Aufbau

Eine VPC (`192.168.0.0/16`) in eu-central-1 mit vier Subnetzen und 13 VMs, alle Ubuntu 24.04.

| Zone | VM | Aufgabe |
|---|---|---|
| public `192.168.20.0/24` | vm-bastion | einziger SSH-Zugang von außen |
| | vm-proxy | HAProxy, leitet per SNI weiter (SSL-Passthrough) |
| management `192.168.10.0/24` | vm-ca | step-ca, stellt die internen TLS-Zertifikate aus |
| | vm-dns | Bind9 für `homelab.local` |
| | vm-storage | NFS, später für Kubernetes-Volumes |
| internal `192.168.30.0/24` | vm-vault | HashiCorp Vault |
| | vm-gitlab | GitLab CE |
| | vm-db | PostgreSQL für GitLab und Keycloak |
| | vm-keycloak | Keycloak, Anmeldung per OIDC |
| kubernetes `192.168.40.0/24` | vm-k8s-master | Control Plane |
| | vm-k8s-worker-01 bis 03 | Worker |

Nur Bastion und Proxy haben eine öffentliche IP. Alle anderen VMs gehen über ein
NAT-Gateway nach außen und sind von außen nicht erreichbar. Zwischen den Zonen regeln
Security Groups, wer mit wem reden darf. Auf jeder VM läuft zusätzlich UFW.

## Ordner

```
infrastructure/     Terraform: VPC, Subnetze, Security Groups, EC2, Outputs
configuration/      Ansible
  inventories/      Hosts und Variablen
  playbooks/        management, security, platform, kubernetes, site
  roles/            eine Rolle pro Dienst
```

Rollen: common, hardening, dns, nfs, step-ca, vault, postgresql, keycloak, gitlab, proxy,
k8s-common, k8s-master, k8s-worker.

## Benutzen

Voraussetzungen: AWS-Konto, Terraform, Ansible, ein EC2 Key Pair, ein S3-Bucket für den
Terraform-State (Name in `infrastructure/backend.tf` anpassen).

```
cd infrastructure
cp example.tfvars terraform.tfvars
terraform init
terraform apply
```

Danach in `configuration/ansible.cfg` den Platzhalter `BASTION_IP` durch die öffentliche
IP der Bastion ersetzen (steht in den Terraform-Outputs).

```
cd configuration
ansible-galaxy collection install -r requirements.yml
cp inventories/homelab/group_vars/all/vault.example.yml inventories/homelab/group_vars/all/vault.yml
# Passwörter eintragen, dann:
ansible-vault encrypt inventories/homelab/group_vars/all/vault.yml
ansible-playbook playbooks/site.yml
```

Am Ende `terraform destroy`, sonst laufen die Kosten weiter.

## Offene Punkte

- Dienste nach dem Aufbau systematisch prüfen (DNS, Zertifikate, Logins, Zonen-Trennung)
- Die Keycloak-Adminkonsole ist über den Proxy von außen erreichbar. Das muss zu.
- Kubernetes: Cluster prüfen, dann Ingress und cert-manager
- Backups und Erneuerung der Zertifikate

## Zur Arbeitsweise

Ich habe bei diesem Projekt mit Claude Code gearbeitet, als Tutor und zum gemeinsamen
Programmieren. Vieles in den Rollen ist so entstanden. Mir war wichtig, dass ich verstehe,
was ich da aufbaue, deshalb ist das Projekt auch langsamer gewachsen, als es mit reinem
Generieren möglich wäre.
