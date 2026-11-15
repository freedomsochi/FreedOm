# FreeDom Agents

Отдельный Eve runtime для команды проекта FreeDom. Публичный сайт FreeDom и его Production не входят в этот проект.

## Команда

- **Координатор:** принимает большое ТЗ, анализирует контекст, распределяет работу, сводит результаты и организует проверку.
- **Designer:** визуальная система, композиция страниц, адаптивность, фотоматериалы.
- **Programmer:** техническая архитектура, HTML/CSS/JS, интеграции и технические исправления.
- **Motion:** анимации, переходы, Orbit, drag/inertia/snap и reduced motion.
- **Tester:** функциональные, адаптивные, accessibility, security и regression-проверки.
- **Mentor:** анализ итогов, повторяющихся ошибок и предложения по улучшению базы знаний и инструкций.

Пять специалистов объявлены как Eve subagents в `agent/subagents/`. Подагенты имеют изолированные authored capabilities: root-only инструменты и расширения не наследуются ими автоматически.

## Разделение GitHub-доступа

- Координатор: собственный `repo-explorer` (read-only).
- Designer, Motion, Tester: каждый имеет собственное подключение `repo-explorer` (read-only).
- Programmer: собственное подключение `maintainer`; Gist-инструменты исключены, операции записи должны проходить встроенные approval gates.
- Mentor: без GitHub extension и без права самостоятельно записывать изменения.

Эта конфигурация проверена статически по файлам репозитория. Фактическая авторизация коннектора, доступность инструментов и поведение approval gates ещё требуют проверки в live Eve session.

## Vercel project

- Отдельный проект: `freedom-agents`.
- Project ID: `prj_m4M7FQM0kWhVZPcSMXWdOB11ZN55`.
- Repository: `freedomsochi/FreedOm`.
- Root Directory: `agent-runtime`.
- Node.js: 24.x.
- Текущая рабочая ветка: `freedom-autonomy-v2-2026-11-15`.
- Текущий commit SHA следует смотреть в заголовке этой ветки GitHub, чтобы документация не содержала устаревающий hash.
- Последняя попытка создать Preview deployment была отклонена с `402 payment_required` из-за дневного лимита деплоев. Текущий коммит ещё не подтверждён сборкой и Preview.
- Web Chat и Eve API должны оставаться на одном защищённом Vercel URL.

Публичный проект `freed-om` и его Production не изменяются. Не отключать Vercel Deployment Protection и не добавлять неприкрытый custom domain: текущий канал Eve использует `none()` за этой edge-защитой.

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

Проверка прямого подключения к Yandex AI Studio:

```bash
npm run test:provider
```

Smoke test требует `YANDEX_API_KEY`, `YANDEX_FOLDER_ID` и опционально `YANDEX_MODEL_URI` в локальном окружении. Он проверяет прямой Chat Completions запрос, но не является тестом Eve runtime или AI SDK adapter.

## Доступ к модели

Все шесть агентов используют общий адаптер `agent/provider.ts` на базе `@ai-sdk/openai` и OpenAI-совместимого Chat Completions API Yandex AI Studio.

В Vercel Environment Variables для Preview нужны:
- `YANDEX_API_KEY` — секретная часть API-ключа сервисного аккаунта.
- `YANDEX_FOLDER_ID` — ID каталога Yandex Cloud.
- `YANDEX_MODEL_URI` — полный URI модели, например `gpt://<folder-id>/yandexgpt-5.1`.

Адаптер использует `https://ai.api.cloud.yandex.net/v1`, заголовок `Authorization: Api-Key`, передаёт Folder ID через `OpenAI-Project` и вызывает модель через `.chat()`.

Не помещать API keys в GitHub, исходники, логи, чат или клиентские переменные. Не включать Production scope для этих credentials на этапе тестирования.

Сервисный аккаунт имеет подтверждённую владельцем роль `ai.languageModels.user`; на скриншоте API-ключа видна область `yc.ai.languageModels.execute`. В текущей документации Yandex для базового Chat Completions запроса также указан scope `yc.ai.foundationModels.execute`, тогда как инструкция создания AI Studio API-ключа перечисляет `yc.ai.languageModels.execute` для Model Gallery. До первого реального запроса это расхождение остаётся открытым; не расширять права ключа без результата теста.

## Проверки и ограничения

Статические файлы подтверждают структуру шести агентов, изоляцию их инструкций и назначенные GitHub presets. Это не подтверждает успешную работу модели, коннектора, делегации или approvals в runtime.

После Preview необходимо проверить:
1. прямой вызов YandexGPT;
2. Eve build и Next.js build;
3. регистрацию координатора и пяти специалистов;
4. streaming и function calling;
5. read-only GitHub доступ дизайнеру, motion и tester;
6. approval-gated write программиста;
7. вызов каждого специалиста координатором;
8. Web Chat на desktop и mobile.

Не заявлять о полноценной автономности до прохождения этих проверок.

## Безопасность

- Не писать в `main`, не сливать PR и не публиковать публичный FreeDom Production.
- Не выполнять Supabase schema/data/grant/RLS changes, платежи, бронирования или необратимые операции без отдельного разрешения владельца.
- Не помещать service-role keys, provider tokens, passwords или private keys в исходники.
- Отделять статический анализ, build, API smoke test и реальное браузерное тестирование.
