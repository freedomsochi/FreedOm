# Technical Architecture Knowledge

Проверенные технические решения и ограничения.

## Agent runtime
- Eve project расположен в agent-runtime.
- Установленная версия Eve: 1.0.0-rc.6 (по package.json).
- Root Orchestrator имеет GitHub preset repo-explorer.
- Designer, Motion и Tester имеют read-only repo-explorer.
- Programmer имеет maintainer preset и является единственным репозиторным writer.
- Mentor не имеет GitHub write tools.

## Ограничения безопасности
- Не публиковать Production и не менять main без отдельного согласия владельца.
- Не отключать Vercel SSO.
- Не менять Supabase schema, RLS, grants, платежи или реальные данные без отдельного согласования.
- Секреты хранить только в защищённых server-side environment variables.

## Provider
- Выбран Yandex AI Studio; общий адаптер находится в `agent/provider.ts`.
- Используется `@ai-sdk/openai` 4.x, соответствующий AI SDK 7 в Eve `1.0.0-rc.6`.
- Endpoint: `https://ai.api.cloud.yandex.net/v1`, Chat Completions.
- Модель задаётся полным URI через `YANDEX_MODEL_URI`; каталог — `YANDEX_FOLDER_ID`; секрет — `YANDEX_API_KEY`.
- Для function calling используется `provider.chat()`; Yandex документирует tool calls для Chat Completions.
- Build и runtime health не подтверждают рабочую авторизацию. Реальный вызов и делегация ожидают установки Preview credentials.
