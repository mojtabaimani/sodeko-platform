# Sodeko IT Solution

This design serves as a comprehensive solution tailored to meet Sodeko's precise requirements, grounded in platform engineering and gitOps principles. The core of this approach revolves around the repository, serving as the singular source of truth. Changes made to the repository are seamlessly pulled by ArgoCD from within the cluster, maintaining synchronization and curbing manual deviations. Notably, the existing Kubernetes cluster, a well-established container management system, serves as the foundation for the teams' operations.

## Kubernetes Clusters and Teams:
- The architecture involves two distinct Kubernetes clusters: one dedicated to production (prd), and the other to dev/test/acceptance environments (dta).
- Each team is assigned a specific namespace aligned with various environments, ensuring that access is restricted to their designated namespaces.

## GitOps Approach:
- The solution capitalizes on ArgoCD, a leading GitOps tool, to harmonize git repositories with the actual operational environment.
- Services can be developed in Helm chart or Kustomize formats, or simply as directories housing straightforward yaml files.
- A clear separation between configurations and templates is implemented, allowing configurations to adapt to different environments.
- Changes to the code that are merged into the main branch automatically trigger deployment to the test environment. Subsequent tagging of the main branch for acceptance or production enables streamlined deployment to these respective stages.
- ArgoCD plays a pivotal role in maintaining synchronization; any manual alterations within the cluster are reverted back to align with the code.

## Git Repositories:
### sodeko-platform-services:
- This repository encompasses self-service tools catering to business teams.
- Core platform services, such as Grafana, Prometheus, Sealed-Secrets, and Loki, are deployed across clusters for universal team access.
- A clear distinction between applications and configurations is observed, with configuration values tailored to individual environments.
- ArgoCD is harnessed to enable GitOps and automation using the app-of-the-apps pattern.
- Real-time changes to configuration values prompt automatic deployment by ArgoCD.
- Version-tagged platform tools empower teams to independently opt for updates.
- The platform repository also serves as the repository for namespace definitions vital to other teams.

### sodeko-green-services/sodeko-blue-services/etc.:
- These repositories are dedicated to distinct teams and environments.
- Utilization of namespaces, thoughtfully provided by the platform team (e.g., blue-tst, blue-acc, blue-prd, red-tst, red-acc, red-prd), streamlines operations.
- Teams can tap into platform team tools and applications while seamlessly adapting values to specific environments.
- Teams have the flexibility to deploy their own applications and services as needed.
- The separation of applications and configurations allows for environment-specific customization.
- Team-specific tools outside of the platform team's purview are also accommodated.
- Application deactivation in a particular environment can be achieved by introducing ".disabled" tags in the application yaml or removing the file entirely.

## Secret Management:
- Encrypted secrets are achieved through sealed-secrets. Encryption is performed with cluster-specific keys, and the encrypted secrets are stored in the repository. This practice facilitates historical tracking, change monitoring, and accountability.
- Role-based access controls within the cluster bolster secret safeguarding.
- The kubeseal command ensures encoded secrets can be securely integrated into the git repository.

This solution framework fosters a robust operational ecosystem that aligns with the exacting demands of Sodeko, emphasizing security, efficiency, and autonomy across teams and environments.
