# FreeDom Agents

Отдельный Eve runtime для команды проекта FreeDom. Публичный сайт FreeDom и его Production не входят в этот проект.

## Команда

- Координатор (root agent): принимает большое ТЗ, распределяет работу, сводит результаты, организует реализацию и проверку.
- Designer: визуальная система, композиция страниц, адаптивность, фотоматериалы.
- Programmer: техническая архитектура, HTML/CSS/JS, интеграции и технические исправления.
- Motion: анимации, переходы, Orbit, drag/inertia/snap и reduced motion.
- Tester: функциональные, адаптивные, accessibility, security и regression-проверки.

Четыре специалиста объявлены как Eve subagents в `agent/subagents/`. Координатор — единственный GitHub writer. Специалисты анализируют задачу и возвращают результаты; изменения репозитория выполняет координатор через GitHub tools с approval gate.

## Vercel project

- Project: `freedom-agents`.
- Root Directory: `agent-runtime`.
- Node.js: 24.x.
- Рабочая интеграционная ветка: `freedom-github-tools-integration`.
- Web Chat подготовлен в ветке `freedom-webchat-sso-2026-11-10`.
- Публичный проект `freed-om` и его Production не изменяются.

## Web Chat и доступ

Next.js Web Chat находится в `apps/web/`. Корневой `vercel.ts` объединяет Next.js и Eve в одном Vercel project и оставляет UI и API на одном origin.

Для доступа используется уже включённый в проекте Vercel Authentication / Deployment Protection. Сейчас защита действует на deployment URLs, кроме custom domains. Поэтому браузерный чат и `/eve/v1` должны оставаться на одном защищённом Vercel URL.

В `agent/channels/eve.ts` стратегия `none()` намеренно используется только за этой edge-защитой: Vercel проверяет доступ до передачи любого запроса приложению. **Нельзя отключать SSO или добавлять неприкрытый custom domain**, пока эта схема активна. Она ограничивает доступ участниками/пользователями, которым разрешён доступ к проекту, но не создаёт отдельную пользовательскую identity внутри Eve. Если понадобится персональная авторизация и аудит действий, нужно отдельно внедрить Better Auth / Sign in with Vercel.

## Локальный запуск и сборка

Требуется Node.js 24.x и Vercel CLI 59.16.0 или новее.

```bash
npm install
npm run dev:all
```

Проверки сборки:

```bash
npm run build
npm run build:web
```

## Доступ к модели

Модель координатора — `openai/gpt-5.4`, через Vercel AI Gateway.

- В локальной среде нужен `AI_GATEWAY_API_KEY` либо свежий `VERCEL_OIDC_TOKEN`.
- В production Vercel может автоматически предоставлять OIDC token, если для проекта включён Secure Backend Access / OIDC Federation.
- Не помещать API keys и OIDC tokens в GitHub или исходники. Если OIDC Federation не включён, включить его в Vercel project settings либо настроить AI Gateway API key через Vercel Environment Variables.

## Что уже проверено в изолированной среде

- Eve build завершился успешно; диагностика обнаружения агентов — 0 ошибок и 0 предупреждений.
- Next.js production build завершился успешно.
- Web Chat отдал HTTP 200.
- `GET /eve/v1/health` вернул `200 ready`.
- `GET /eve/v1/info` подтвердил root agent `freedom-agents` и регистрацию subagents: `designer`, `programmer`, `motion`, `tester`.
- Реальный модельный вызов из локального sandbox не завершился: в нём отсутствовали `VERCEL_OIDC_TOKEN`, `AI_GATEWAY_API_KEY` и `OPENAI_API_KEY`. Это не проверка production model access. Реальную делегацию четырём специалистам пока нельзя считать подтверждённой.

## Безопасность и ограничения

- Не писать в `main`, не сливать PR и не публиковать публичный FreeDom Production.
- Не выполнять production writes, платежи, бронирования, удаления или необратимые изменения Supabase без отдельного разрешения владельца.
- Не помещать credentials, admin passwords, service-role keys, provider tokens или private keys в репозиторий.
- Отличать статические проверки и build от реального browser/device тестирования.
- Историю FreeDom пишет владелец; агенты готовят макет и медиаслоты, не выдумывая факты о доме.
