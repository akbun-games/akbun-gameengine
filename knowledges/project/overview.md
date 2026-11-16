---
type: Project Overview
title: akbun-gameengine 프로젝트 개요
description: akbun-gameengine repo의 목적, 운영 방식, 현재 상태.
tags: [project, process]
status: draft
generated: { by: human:choisungwook, at: 2026-11-16T09:00:00Z }
sources:
  - id: okf-spec
    resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
    title: Open Knowledge Format v0.2 spec
---

# akbun-gameengine 프로젝트 개요

## 현재 상태

repo를 막 생성한 단계다. 코드는 아직 없다.

## 운영 방식

- private repo + GitHub free tier라서 GitHub Actions는 릴리즈에만 사용한다. 나머지 CI는 로컬에서 실행한다.
- AI agent가 wiki처럼 읽고 쓰는 지식은 `knowledges/`에 OKF v0.2 형식으로 관리한다.[^okf-spec]
- `git push`, `gh pr create` 전에 Claude hook(`.claude/hooks/check-knowledges.sh`)이 knowledges 업데이트 여부와 OKF 형식을 검사한다.

[^okf-spec]: Open Knowledge Format v0.2 spec
