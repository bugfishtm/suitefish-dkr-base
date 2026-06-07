# Suitefish Base Image

## 🗒️ Overview

This repository contains the **internal base Docker image** used for all Suitefish application instances and deployment pipelines. It is designed to provide a consistent, secure, and up-to-date foundation for Suitefish development and deployment environments.

---

## ✋ Usage

Use it as a base for your own Dockerfiles:

```dockerfile
FROM bugfishtm/sf-base:latest

# Add your application setup here
# ...other build steps...
```

---

## 🔹 Features  
- 📦 Base Image
	- Image template for deployed sites and suitefish instances.
	- Pre-installed system libraries and tools required by Suitefish services
	- Optimized for fast build and deployment in CI/CD pipelines
	- Regularly updated for security and stability
	- Serves as the parent image for all Suitefish Dockerized applications
- ❌ No CMS functionality – This image does not provide any actual CMS features.  
- 🌐 Learn more – Visit [Suitefish-CMS](https://github.com/bugfishtm/suitefish-cms) for details on Suitefish CMS and its Docker module capabilities.  

---

## 📖 Documentation

The following documentation is intended for both end-users and developers.

| Description | Link  | Scope  |
|----------------|----------------------------|--------|
| Suitefish Tutorial Videos | [https://www.youtube.com/playlist?list=PL6npOHuBGrpAfrpUzQPTOWdqoCnhq1oP0](https://www.youtube.com/playlist?list=PL6npOHuBGrpAfrpUzQPTOWdqoCnhq1oP0)| Users |
| Suitefish Documentation                                                                                              | [https://bugfishtm.github.io/suitefish-cms/](https://bugfishtm.github.io/suitefish-cms/)| Developers |

Relevant github repositories related to suitefish-cms.

| Description | Link  | Scope  |
|----------------|----------------------------|---|
| Suitefish-CMS | [https://github.com/bugfishtm/suitefish-cms](https://github.com/bugfishtm/suitefish-cms)| Users |

Relevant docker repositories related to suitefish-cms.

| Description | Link  | Scope  |
|----------------|----------------------------|--------|
| Suitefish Docker Base Image | [https://hub.docker.com/r/bugfishtm/sf-base](https://hub.docker.com/r/bugfishtm/sf-base)| Developers |
| Suitefish Docker Image  | [https://hub.docker.com/r/bugfishtm/suitefish](https://hub.docker.com/r/bugfishtm/suitefish) | Users |

---

## 🌱 Contributing to the Project

Thank you for your interest in this project.

At this time, this repository is **not open for external contributions**.  
Please do **not** submit pull requests or patches.

- Pull requests from external contributors are not accepted.
- Any unsolicited pull requests will be closed without review.
- All code in this repository is maintained by the project owner.
- By design, no third‑party code will be merged into this project via GitHub.

If you encounter a bug or have an enhancement suggestion, please check the "Issues" section of our GitHub repository or visit our official website for guidance before beginning any work on it.

---

## 🤝 Community Guidelines

We’re focused on developing innovative solutions and advancing technology. By being part of this, you contribute to our progress.

Positive guidelines include being kind, empathetic, and respectful in all interactions. It is important to engage thoughtfully and offer constructive, solution-oriented feedback. Fostering an environment of collaboration, support, and mutual respect is essential.

Unacceptable behaviors include harassment, hate speech, or offensive language. Personal attacks, discrimination, or any form of bullying are not tolerated. Sharing private or sensitive information without explicit consent is strictly prohibited.

Together, we can partner to achieve common goals by following guidelines designed to promote effective collaboration and positive teamwork.

---

## 🛡️ Security Policy

I take security seriously and appreciate responsible disclosure. If you discover a vulnerability, please follow these steps:

- **Do not** report it via public GitHub issues or discussions. Instead, please contact the [security@bugfish.eu](mailto:security@bugfish.eu) email address directly.  
- Provide as much detail as possible, including a description of the issue, steps to reproduce it, and its potential impact.  

I aim to acknowledge reports within **2–4 weeks** and will update you on our progress once the issue is verified and addressed.

This software is provided as-is, without any guarantees of security, reliability, or fitness for any particular purpose. We do not take responsibility for any damage, data loss, security breaches, or other issues that may arise from using this software. By using this software, you agree that We are not liable for any direct, indirect, incidental, or consequential damages. Use it at your own risk.

---

## 📜 License Information

Take a look at the suitefish github repository for license information.

🐟 Bugfish 