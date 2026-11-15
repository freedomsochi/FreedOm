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
- Текущий исходный код использует Eve OpenAI helper с моделью gpt-5.4.
- Функциональная совместимость и работа runtime ещё не подтверждены.
- Провайдер не менять до отдельной проверки и решения владельца.
