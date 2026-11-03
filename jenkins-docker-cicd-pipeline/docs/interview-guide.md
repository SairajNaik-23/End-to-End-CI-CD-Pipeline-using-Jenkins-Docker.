# Interview Guide: Jenkins & Docker CI/CD Pipeline

## 60-second explanation

> "I built a CI/CD pipeline with GitHub, Jenkins and Docker. When a developer pushes code, a GitHub webhook triggers the Jenkins job immediately, with no polling. The declarative Jenkinsfile has six stages: checkout, run unit tests inside a Node container, build a Docker image tagged with the build number and git commit, push it to Docker Hub using credentials from the Jenkins store, deploy it to an EC2 server over SSH, and run a smoke test on the health endpoint. The deploy script waits for the container's Docker health check, and if the new version isn't healthy it automatically rolls back to the previous image. This turned a manual 10-minute deployment into a fully automated one of about 2 minutes."

## Common questions

**Q: What is the difference between CI and CD?**
CI (Continuous Integration): every push is automatically built and tested, so problems are found early. CD (Continuous Delivery/Deployment): the tested build is automatically released. Delivery means one click to release; deployment means fully automatic. My pipeline does continuous deployment.

**Q: Webhook vs Poll SCM?**
Poll SCM makes Jenkins ask GitHub every few minutes whether anything changed, which wastes resources and adds delay. With a webhook, GitHub tells Jenkins the moment a push happens, so it's instant and efficient.

**Q: Declarative vs scripted pipeline?**
Declarative (`pipeline { stages { ... } }`) has a fixed, readable structure with built-in `post`, `options` and `triggers`. Scripted is plain Groovy: more flexible but harder to read. I used declarative, with a small `script {}` block where logic was needed.

**Q: Why is the Jenkinsfile in the repo (Pipeline as Code)?**
The pipeline is version-controlled with the app: changes are reviewed in PRs, history is kept, and the job can be recreated anywhere.

**Q: How do you handle secrets?**
Docker Hub token and SSH key are stored in Jenkins Credentials and injected with `withCredentials` and `sshagent`. Jenkins masks them in logs. Nothing is in Git. `docker login --password-stdin` keeps the token out of the process list.

**Q: How do you roll back?**
Two layers. Automatic: `deploy.sh` records the current image, starts the new one and waits for `healthy`; if that fails, it starts the previous image again. Manual: every build has a unique tag, so I can redeploy any older tag.

**Q: Why tag images with build number + git SHA?**
`latest` doesn't tell you what's running. A unique tag maps each container to an exact commit and build log.

**Q: CMD vs ENTRYPOINT? COPY vs ADD?**
CMD is the default command and can be overridden. ENTRYPOINT is the fixed executable, and CMD becomes its arguments. COPY just copies files; ADD can also fetch URLs and extract tar files. Prefer COPY unless you need those extras.

**Q: How did you keep the Docker image small and secure?**
Alpine base image, only production dependencies (`--omit=dev`), `.dockerignore`, non-root `USER node`, and a HEALTHCHECK.

**Q: What would you improve?**
Add a SonarQube code-quality stage and a Trivy image scan, deploy to Kubernetes or ECS instead of a single server, use Blue/Green deployment for zero downtime, run Jenkins agents in containers so builds are isolated, and send Slack notifications in the `post` block.
