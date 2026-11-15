# Known Bugs and Runtime Blockers

## Agent runtime
- Функциональная работа модели и делегирование специалистов ещё не подтверждены реальным Agent Run.
- В проверенном Vercel project query список environment variables вернул пустой результат; наличие ключа в нужном scope не подтверждено.
- Vercel Agent Runs API вернул 403 для текущего подключения; отсутствие данных о запусках не означает, что запусков не было.
- Runtime logs не удалось прочитать за 30 дней: Hobby retention ограничивает доступный период примерно одним часом.
- Eve build warning: каталог `agent/knowledge/` не поддерживается как capability directory и игнорируется. Документы перенесены сюда, за пределы agent workspace.

## Правило обновления
Для каждого дефекта указывать дату, способ воспроизведения, severity, evidence, ответственного, статус и PR/commit исправления.
