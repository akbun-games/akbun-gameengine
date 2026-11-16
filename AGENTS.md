# AGENTS.md

## 작업 전: 과거 히스토리 파악

이 repo의 지식과 히스토리는 `knowledges/`에 [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) 형식으로 저장되어 있다. 작업을 시작하기 전에 반드시 아래 순서로 읽는다.

1. `knowledges/index.md` - 어떤 concept가 있는지 확인한다.
2. `knowledges/log.md` - 최근 변경 히스토리를 확인한다.
3. 작업과 관련된 concept 문서 - frontmatter를 먼저 보고, 필요할 때만 body를 읽는다.

concept를 읽을 때 trust 신호를 확인한다.

- `status: deprecated`는 과거 기록이다. 현재 사실로 쓰지 않는다.
- `stale_after`가 지났으면 코드와 대조해서 확인한다.
- `verified`가 없으면 unverified다. 코드와 다르면 코드를 믿고 concept를 고친다.

`examples/okf-acme-retail/`은 OKF 작성법 참고용 공식 예제다. 프로젝트 지식이 아니므로 여기 내용을 사실로 쓰지 않는다.

## 작업 후: knowledges 업데이트

코드를 바꾸면 같은 브랜치에서 `knowledges/`도 업데이트한다. `git push`와 `gh pr create`는 Claude hook이 검사하며, knowledges 변경 없이 코드만 바뀌면 차단된다.

- 새 결정, 시스템 구조, 운영 절차는 concept 문서로 추가하거나 기존 문서를 고친다. 디렉터리는 필요할 때 만든다. 예: `decisions/`, `systems/`, `playbooks/`
- `knowledges/log.md` 맨 위 날짜(`## YYYY-MM-DD`)에 한 줄 기록을 추가한다.
- 새 concept는 해당 디렉터리의 `index.md`에 등록한다. 새 디렉터리를 만들면 `index.md`도 만들고 상위 `index.md`에 등록한다. hook이 `index.md` 없는 디렉터리를 차단한다.

## concept 작성 규칙 (OKF v0.2)

concept 문서는 아래 frontmatter로 시작한다. `type`만 필수이고 나머지는 해당될 때 채운다.

```yaml
---
type: Decision                 # 필수. 예: Project Overview, Decision, System, Playbook
title: 짧은 제목
description: 한 문장 요약 (index.md에도 그대로 쓴다)
tags: [tag1, tag2]
status: draft                  # draft | stable | deprecated, 생략 시 stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-15T09:00:00Z }
verified:                      # 사람이 검토했을 때만 추가한다
  - { by: human:<id>, at: 2026-11-15T10:00:00Z }
stale_after: 2027-05-15T00:00:00Z
sources:
  - id: pr-12
    resource: https://github.com/akbun-games/akbun-gameengine/pull/12
    title: 근거가 된 PR, 이슈, 문서
---
```

- `generated.by`는 actor 규칙을 따른다. agent는 `<producer>/<version>`, 사람은 `human:<id>`, 자동화는 `process:<id>`.
- agent는 스스로를 `verified`에 넣지 않는다. 사람이 확인한 경우에만 `human:` actor로 추가한다.
- 내용을 바꾸면 `generated.at`을 갱신한다.
- 낡은 concept는 지우지 않고 `status: deprecated`로 바꾼다.
- concept 사이 링크는 bundle 기준 절대경로를 쓴다. 예: `[개요](/project/overview.md)`
- `index.md`, `log.md`는 예약 파일명이다. concept 이름으로 쓰지 않는다.

## CI

private repo free tier라서 GitHub Actions는 릴리즈에만 쓴다. 그 외 CI는 로컬에서 실행한다. knowledges 검사를 수동으로 돌리는 명령은 아래와 같다.

```sh
./.claude/hooks/check-knowledges.sh
```
