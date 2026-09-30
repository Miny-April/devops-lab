# DevOps Lab







DevOps Foundations: Learning and Lab Testing Guide

Git, Docker, Kubernetes, Ansible | 8 weeks | 1 to 1.5 hours per day
How to use this guide: For every lab, do the Steps, then run the Test commands and compare with Expected result. Tick the checkbox only when the test passes. If it fails, use the Troubleshooting table at the end.
________________________________________
0. Big Picture
Tool	Problem it solves	One-line idea
Git	Who changed what, and can I go back?	Version control
Docker	It works on my machine	Package app and dependencies into a container
Kubernetes	How to run many containers reliably?	Orchestration: scale, heal, update
Ansible	How to configure many servers the same way?	Agentless automation with YAML playbooks
Learning order: Linux basics, Git, Docker, Kubernetes, Ansible, Capstone.
________________________________________
1. Phase 0: Lab Setup (Days 1-3)
Choose one environment: Windows with WSL2 Ubuntu (wsl --install), Mac/Linux terminal, or an Ubuntu VM. Accounts: GitHub, Docker Hub. Editor: VS Code.
Lab 0: Linux warm-up
mkdir -p ~/devops/lab0 && cd ~/devops/lab0
echo "hello" > a.txt && cp a.txt b.txt
ls -l && cat b.txt
chmod +x a.txt && ls -l a.txt
sudo apt update
Test: ls shows a.txt b.txt; ls -l a.txt shows an x permission.
•	☐ Lab 0 passed
________________________________________
2. Phase 1: Git (Weeks 1-2)
Concepts: repository, commit (snapshot), branch, remote, flow: working directory, staging, commit, push.
Install and configure
sudo apt install git -y
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
Test: git --version prints a version; git config --list | grep user shows your name and email.
•	☐ Git installed
Lab 1: First repo
mkdir devops-lab && cd devops-lab && git init
echo "# DevOps Lab" > README.md
git add README.md && git commit -m "Initial commit"
Test: git log --oneline shows 1 commit; git status says "nothing to commit, working tree clean".
•	☐ Lab 1 passed
Lab 2: Branch and merge
git switch -c feature-hello
echo "Hello DevOps" > hello.txt
git add . && git commit -m "Add hello"
git switch main && git merge feature-hello
Test: ls on main shows hello.txt; git log --oneline shows 2 commits.
•	☐ Lab 2 passed
Lab 3: GitHub remote
git remote add origin https://github.com/<you>/devops-lab.git
git push -u origin main
Test: Refresh the GitHub repo page; you see README.md and hello.txt. Then run git clone https://github.com/<you>/devops-lab.git /tmp/clone-test and confirm files exist.
•	☐ Lab 3 passed
Lab 4: Merge conflict (on purpose)
1.	On main, edit line 1 of README.md and commit.
2.	git switch -c conflict-test HEAD~1, edit the same line differently, commit.
3.	git switch main && git merge conflict-test
4.	Open README.md, remove the <<<<<<<, =======, >>>>>>> markers, keep the right text, then git add README.md && git commit.
Test: git status is clean and README.md has no conflict markers (grep "<<<<" README.md returns nothing).
•	☐ Lab 4 passed
Git self-check (answer without notes)
1.	What is the difference between add, commit, and push?
2.	What does git pull do?
3.	Why use branches?
4.	What goes in .gitignore?
________________________________________
3. Phase 2: Docker (Weeks 3-4)
Concepts: image (recipe), container (running instance), Dockerfile, registry, volume, network.
Install
Follow docs.docker.com/engine/install/ubuntu (or Docker Desktop).
sudo usermod -aG docker $USER    # log out and back in
docker run hello-world
Test: Output contains "Hello from Docker!"
•	☐ Docker installed
Lab 5: Run existing containers
docker run -d --name web -p 8080:80 nginx
docker ps
curl http://localhost:8080
docker logs web
docker stop web && docker rm web
Expected: docker ps lists web; curl returns HTML containing "Welcome to nginx!". After cleanup, docker ps -a no longer lists web.
•	☐ Lab 5 passed
Lab 6: Build your own image
app.py:
from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.end_headers()
        self.wfile.write(b"Hello from my container!")
HTTPServer(("", 5000), H).serve_forever()
Dockerfile:
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
docker build -t my-app:1.0 .
docker run -d --name my-app -p 5000:5000 my-app:1.0
Test: curl http://localhost:5000 prints Hello from my container!; docker images | grep my-app shows tag 1.0.
•	☐ Lab 6 passed
Lab 7: Volumes (data survives)
docker volume create mydata
docker run --rm -v mydata:/data alpine sh -c "echo saved > /data/f.txt"
docker run --rm -v mydata:/data alpine cat /data/f.txt
Expected: Second command prints saved even though the first container is gone.
•	☐ Lab 7 passed
Lab 8: Docker Compose
docker-compose.yml:
services:
  web:
    build: .
    ports:
      - "5000:5000"
  cache:
    image: redis:7
docker compose up -d --build
docker compose ps
docker compose exec cache redis-cli ping
docker compose down
Expected: Both services show "running"; redis replies PONG.
•	☐ Lab 8 passed
Lab 9: Push to Docker Hub
docker login
docker tag my-app:1.0 <user>/my-app:1.0
docker push <user>/my-app:1.0
Test: Image appears at hub.docker.com under your account. Then docker rmi <user>/my-app:1.0 && docker pull <user>/my-app:1.0 works.
•	☐ Lab 9 passed
Lab 10: Repeatable automation script
deploy.sh:
#!/bin/bash
set -e
docker build -t my-app:latest .
docker rm -f my-app 2>/dev/null || true
docker run -d --name my-app -p 5000:5000 my-app:latest
sleep 2
curl -fs http://localhost:5000 && echo " -> Deploy OK"
chmod +x deploy.sh && ./deploy.sh && ./deploy.sh
Expected: Runs twice with no errors (repeatable) and prints "Deploy OK" each time.
•	☐ Lab 10 passed
Docker self-check
1.	Image vs container?
2.	What does -p 8080:80 mean?
3.	Why does docker rm not delete a volume?
4.	What is the difference between CMD and RUN?
________________________________________
4. Phase 3: Kubernetes (Weeks 5-6)
Concepts: cluster (control plane and nodes), Pod, Deployment, Service, ConfigMap/Secret, kubectl.
Install (minikube)
Install kubectl (kubernetes.io/docs/tasks/tools) and minikube (minikube.sigs.k8s.io/docs/start).
minikube start
kubectl get nodes
Test: Node minikube shows STATUS Ready.
•	☐ Cluster running
Lab 11: Imperative deployment
kubectl create deployment web --image=nginx
kubectl expose deployment web --type=NodePort --port=80
kubectl get pods,svc
minikube service web --url
Expected: Pod is Running; the URL opens the nginx welcome page (curl <url>).
•	☐ Lab 11 passed
Lab 12: Declarative YAML
Push your image first (Lab 9). deployment.yaml:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: <user>/my-app:1.0
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-svc
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 5000
kubectl apply -f deployment.yaml
kubectl get pods -l app=my-app
curl $(minikube service my-app-svc --url)
Expected: 3 pods Running; curl prints Hello from my container!.
•	☐ Lab 12 passed
Lab 13: Scale, self-heal, update, rollback
kubectl scale deployment my-app --replicas=5
kubectl get pods -l app=my-app                 # 5 pods
kubectl delete pod <one-pod-name>
kubectl get pods -l app=my-app -w              # a new pod appears automatically
kubectl rollout history deployment/my-app
kubectl rollout undo deployment/my-app
Expected: Replica count returns to 5 after deleting a pod (self-healing). Rollout commands succeed.
•	☐ Lab 13 passed
Lab 14: ConfigMap
kubectl create configmap app-config --from-literal=GREETING=Hi
kubectl get configmap app-config -o yaml
Expected: YAML shows GREETING: Hi. Stretch goal: inject it into the Deployment as an environment variable.
•	☐ Lab 14 passed
Debugging toolkit
kubectl describe pod <name>, kubectl logs <pod>, kubectl get events --sort-by=.lastTimestamp, kubectl exec -it <pod> -- sh
Kubernetes self-check
1.	Pod vs Deployment vs Service?
2.	What happens if a Pod crashes?
3.	Why does the Service use labels and selectors?
4.	Difference between kubectl apply and kubectl create?
________________________________________
5. Phase 4: Ansible (Week 7)
Concepts: control node, inventory, playbook, module, idempotency (running twice makes no extra changes).
Install
sudo apt install ansible sshpass -y
ansible --version
Test: Version prints without error.
•	☐ Ansible installed
Lab 15: Create target machines with Docker (no VMs needed)
Dockerfile.target:
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y openssh-server python3 sudo \
 && mkdir -p /run/sshd \
 && useradd -m -s /bin/bash ansible && echo 'ansible:ansible' | chpasswd \
 && echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
docker build -f Dockerfile.target -t ansible-target .
docker run -d --name node1 -p 2201:22 ansible-target
docker run -d --name node2 -p 2202:22 ansible-target
Test: docker ps lists node1 and node2.
•	☐ Lab 15 passed
Lab 16: Inventory and ad-hoc commands
inventory.ini:
[web]
node1 ansible_host=127.0.0.1 ansible_port=2201
node2 ansible_host=127.0.0.1 ansible_port=2202

[web:vars]
ansible_user=ansible
ansible_password=ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible -i inventory.ini all -m ping
ansible -i inventory.ini all -m command -a "uptime"
Expected: Both nodes reply "ping": "pong" in green.
•	☐ Lab 16 passed
Lab 17: First playbook
site.yml:
- name: Configure web nodes
  hosts: web
  become: true
  vars:
    message: "Deployed by Ansible"
  tasks:
    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: true

    - name: Deploy homepage
      ansible.builtin.copy:
        content: "<h1>{{ message }}</h1>"
        dest: /var/www/html/index.html
ansible-playbook -i inventory.ini site.yml
ansible-playbook -i inventory.ini site.yml     # run again
ansible -i inventory.ini all -m command -a "cat /var/www/html/index.html" --become
Expected: First run shows changed; second run shows changed=0 (idempotent). The last command prints your message on both nodes.
•	☐ Lab 17 passed
Lab 18: Variables and a second play
Change message to another value with -e message="Version 2" and re-run. Only the copy task should report changed.
•	☐ Lab 18 passed
Lab 19 (stretch): Docker with Ansible on a real VM or WSL
Write a playbook that installs Docker and runs your image using community.docker.docker_container (install with ansible-galaxy collection install community.docker).
•	☐ Lab 19 passed
Ansible self-check
1.	Why is Ansible called agentless?
2.	What is idempotency and why does it matter?
3.	Inventory vs playbook?
4.	When would you use become: true?
________________________________________
6. Phase 5: Capstone (Week 8)
Repo devops-capstone:
devops-capstone/
├── app/          (app.py, Dockerfile)
├── k8s/          (deployment.yaml)
├── ansible/      (inventory.ini, site.yml)
├── Makefile
└── README.md
Acceptance tests (all must pass):
•	☐ git log shows at least 10 meaningful commits and a .gitignore
•	☐ docker build succeeds and the image is on Docker Hub
•	☐ make build, make push, make deploy work from a clean checkout
•	☐ kubectl get pods shows 3 Running replicas; curl on the Service returns your app response
•	☐ Deleting a pod causes it to be recreated automatically
•	☐ Ansible playbook runs twice; second run shows changed=0
•	☐ README explains setup, how to run, and includes architecture notes
•	☐ Repo pushed to GitHub and cloneable by someone else
Makefile starter:
IMAGE=<user>/my-app:1.0
build:
    docker build -t $(IMAGE) app/
push:
    docker push $(IMAGE)
deploy:
    kubectl apply -f k8s/deployment.yaml
________________________________________
7. Troubleshooting
Symptom	Likely cause	Fix
permission denied on docker	User not in docker group	sudo usermod -aG docker $USER, log out and in
Port already in use	Another container or process	docker ps, stop it, or use another host port
ImagePullBackOff in Kubernetes	Wrong image name or private repo	Check kubectl describe pod, verify image is public and tag exists
CrashLoopBackOff	App exits on start	kubectl logs <pod>
Service URL not reachable	Wrong selector or targetPort	kubectl get endpoints my-app-svc should list pod IPs
Ansible UNREACHABLE	Wrong port, user, or password	Test ssh ansible@127.0.0.1 -p 2201 manually
Ansible "sshpass" error	sshpass missing	sudo apt install sshpass
Git push rejected	Remote has newer commits	git pull --rebase, then push
minikube will not start	Docker not running or low resources	Start Docker, then minikube delete && minikube start
Clean up labs:
docker rm -f $(docker ps -aq); docker system prune -f
kubectl delete -f k8s/deployment.yaml; minikube stop
________________________________________
8. Progress Tracker
Week	Topic	Labs	Done
0	Linux and setup	0	[ ]
1-2	Git	1-4	[ ]
3-4	Docker	5-10	[ ]
5-6	Kubernetes	11-14	[ ]
7	Ansible	15-19	[ ]
8	Capstone	All acceptance tests	[ ]
9. Free Resources
Pro Git (git-scm.com/book), Learn Git Branching, Docker Get Started (docs.docker.com), Play with Docker, Kubernetes Basics (kubernetes.io), Killercoda labs, Ansible Getting Started (docs.ansible.com), freeCodeCamp, KodeKloud, TechWorld with Nana.
10. Study Tips
Type commands yourself, break things on purpose, keep a notes.md in Git, read error messages fully, and finish Docker before Kubernetes.
