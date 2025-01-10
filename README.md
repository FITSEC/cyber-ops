# Cyber-Ops Docker Image

This repo provides the source for the ``tjoconnor/cyber-ops`` image discussed in [our SIGITE paper](https://github.com/tj-oconnor/Publications/raw/main/pdf/sigite23fernalld.pdf).

## Publication

Kourtnee Fernalld, TJ OConnor, Sneha Sudhakaran, Nasheen Nur. *Lightweight Symphony: Towards Reducing Computer Science Student Anxiety with Standardized Docker Environments.* Special Interest Group on Information Technology Education (SIGITE 23), Marietta, GA, October 2023. 

## Build Command

```bash
docker build . --tag cyber-ops:latest
```

## Run Command
```bash
docker run --cap-add=SYS_PTRACE --cap-add=SYS_ADMIN --cap-add=audit_control --security-opt seccomp=unconfined --privileged --platform linux/amd64  -ti --name=cyber-ops cyber-ops:latest
```





