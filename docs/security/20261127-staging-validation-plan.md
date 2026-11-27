# FreeDom — единый план staging-валидации безопасности Supabase

Дата: 2026-11-27  
Ветка исходников: `fix/security-rpc-hardening-2026-11-26`  
Статус: подготовка сценария; staging не подтверждён, тесты на БД не запускались.

## 0. Жёсткие границы

- Подключённый Supabase-проект считается production. Не запускать в нём ни один SQL из этого плана.
- Не создавать платный staging/branch и не включать платные сервисы без отдельного согласования.
- Сначала подтвердить наличие отдельного staging-проекта/базы и её идентификатор. Если staging отсутствует — остановиться на подготовке сценария.
- До миграций получить snapshot/backup и проверить, что восстановление реально доступно.
- Создать отдельные тестовые Auth-аккаунты: owner, admin, user-A, user-B. Не назначать роли реальным пользователям по догадке и не копировать production UUID в тестовую базу.
- Все тестовые записи должны иметь явный префикс вроде `STAGING_SECURITY_TEST` и удаляться только в рамках согласованной очистки staging.
- Никаких массовых UPDATE/DELETE исторических данных, переноса user_id, пересчёта `paid_amount`, долгов или балансов.
- Любая production-миграция и production-деплой требуют отдельного явного одобрения после успешного staging.

## 1. До первого SQL: зафиксировать исходное состояние

На staging, а не production:

1. Сверить проект/ref, URL и окружение в Dashboard. Сохранить доказательство, что это отдельный staging.
2. Сделать snapshot; проверить процедуру восстановления.
3. Снять базовые определения и ACL всех функций из миграций: `pg_get_functiondef`, owner, `prosecdef`, `proconfig`, EXECUTE grants.
4. Снять RLS enable/force, политики и grants затрагиваемых таблиц/views.
5. Сохранить row counts и контрольные суммы/агрегаты по bookings, orders, service_orders, event_registrations, payments, payment_allocations и users.
6. Зафиксировать baseline Supabase Security Advisors. Предупреждения классифицировать, не устранять массовым отзывом EXECUTE.
7. Проверить, что тестовые аккаунты созданы и их UUID записаны в закрытом staging-журнале. Роли назначаются только этим UUID.

## 2. Рекомендуемый порядок миграций

Применять небольшими логическими группами; после каждой группы запускать все относящиеся к ней verification SQL и тесты. Если файл отсутствует или его предпосылки не выполняются — остановиться, не пропускать молча.

### Группа A — основа ролей и legacy RPC

1. `supabase/sql/admin-role-foundation.sql` — private.user_roles и role helpers.
2. `supabase/sql/admin-role-foundation-verification.sql` — read-only проверка закрытости схемы/таблицы, RLS, constraints, владельцев и ACL обоих helpers; требовать `PASS_ROLE_FOUNDATION_STATIC_CHECKS`.
3. Назначить `owner` только тестовому owner и `admin` только тестовому admin через контролируемую staging-only процедуру. Обычным пользователям роли не назначать.
4. `supabase/sql/20261127_harden_booking_and_payment_history_rpcs.sql`.
5. `supabase/sql/20261127_admin_rpc_role_migration.sql`.
6. Запустить обе verification-проверки после обоих файлов: они перекрываются на пяти RPC; проверить итоговый guard и ACL, а не только факт выполнения скрипта.
7. `supabase/sql/20261127_harden_remaining_admin_rpcs.sql` + `_verification.sql` — 12 чувствительных RPC только owner.
8. `supabase/sql/20261127_harden_event_registration_payment.sql` + verification — запись оплаты события только owner.
9. `supabase/sql/20261127_pin_admin_read_rpc_search_path.sql` + verification — закрепить search_path у административных read RPC.

### Группа B — новые admin/owner read RPC и совместимость UI

Применять после role foundation и назначения тестового owner:

1. `20261127_admin_dashboard_overview_rpc.sql` + verification.
2. `20261127_admin_finance_overview_guest_identity_rpc.sql` + verification.
3. `20261127_admin_finance_charge_detail_rpc.sql` + verification.
4. `20261127_admin_events_dashboard_rpc.sql` + verification.
5. `20261127_admin_services_dashboard_rpc.sql` + verification.
6. `20261127_restrict_public_booking_confirmation.sql` + verification — owner-only, authenticated EXECUTE, anon/service_role/PUBLIC запрещены.
7. `20261127_admin_guest_booking_rpc_role_hardening.sql` — только payload-minimization/capability follow-up после основной owner-role миграции; не считать его самостоятельной авторизацией.

Каждый новый RPC должен быть проверен как anon, обычный authenticated, admin-only и owner. Все чувствительные CRM, guest identity, finance, event-registration и service-order ответы — owner-only согласно role matrix. UI-скрытие кнопки не считается проверкой авторизации.

### Группа C — публичные сценарии и привязка аккаунта

1. `20261127_harden_public_event_registration.sql` + verification.
2. `20261127_verified_contact_account_linking.sql` + verification/audit. Порядок важен: второй файл устанавливает финальное trigger-only определение `attach_event_user_by_phone()` и закрывает прямой клиентский EXECUTE на пяти trigger-функциях.
3. `20261127_harden_public_room_catalog.sql` + verification.
4. `20261127_restrict_public_event_visibility.sql` + verification.
5. Проверить публичную запись в бронирование через существующий Edge/API-контракт; не подменять её прямой записью в таблицы.

### Группа D — личный кабинет и финансовые поверхности

1. `20261127_user_self_service_reads.sql` + verification: own-row only для двух разных тестовых пользователей.
2. `20261127_revoke_anon_financial_summary_view.sql` + verification — только после подтверждения всех callers и проверки authenticated/service workflows.
3. Проверить прямые SELECT/UPDATE права на финансовые таблицы и RLS. Не применять широкие GRANT/REVOKE изолированно от caller map.
4. Финансовые контрольные суммы после тестов должны совпадать с baseline, за исключением специально созданных и затем удалённых тестовых операций.

### Отдельно, вне DB sequence

- Изменение Edge Function `telegram-notify` — отдельная координированная работа. Нужна совместимость формата Authorization между вызывающей функцией и целевой функцией; не включать в этот SQL rollout и не деплоить автоматически.
- Редиректы legacy admin pages и обновления frontend — выпускать только вместе с соответствующими RPC/ACL и после UI smoke tests.
- Не деплоить фронтенд, который вызывает новый RPC, пока этот RPC и role foundation не прошли staging.

## 3. Матрица акторов: обязательные allow/deny тесты

| Актор | Должно быть разрешено | Должно быть запрещено |
|---|---|---|
| anon | Только публичный каталог комнат; активные и опубликованные события; публичная отправка бронирования/регистрации по предусмотренному контракту | Любые admin RPC/таблицы; guest list/profile; финансы/долги; подтверждение/отмена существующей брони; event payment mutation; чтение скрытых/неактивных событий |
| user-A / user-B | Только собственный профиль, собственные orders/purchases/referrals в пределах разрешённых колонок; публичные формы | Чужие строки user-B/user-A; любые admin/owner RPC; чужая история оплат; финансовые данные; назначение роли себе |
| admin | Только утверждённые операционные RPC бронирования и кухни: очередь/статус/подтверждение/отмена в рамках матрицы | Owner-only guest identity, guest profile/list, CRM overview, debt, finance, charge details, event-registration PII, services/payment writes и owner role assignment |
| owner | Все явно перечисленные owner-only dashboard/CRM/finance/payment операции, если бизнес-валидации пройдены | Чтение/изменение не относящихся к тесту данных сверх заявленного контракта; обход бизнес-валидаций; произвольная смена user_id |
| service_role | Только явно предусмотренные серверные публичные интеграции и сервисные вызовы, проверенные отдельно | Интерактивное подтверждение брони через `confirm_public_booking`; использование service_role в браузере; неявное право на owner-only UI |

**Обязательный тест двух пользователей:** user-A не видит ни одной строки user-B и наоборот. Проверить SELECT и все доступные UPDATE пути; попытка сменить owner/user_id должна отклоняться, а не просто возвращать пустой результат.

**Проверка роли:** admin не является owner; user не может получить роль через user_metadata/app_metadata, RPC общего назначения или прямой доступ к private.user_roles; NULL auth.uid() всегда отказ для административных функций.

## 4. Сценарии целостности данных

### Бронирования и комнаты
- anon получает только согласованные поля каталога: id, name, description, price_per_night, capacity, image_url, booking_mode.
- Форма бронирования получает каталог и создаёт одну запись по штатному API/Edge flow.
- Повторная отправка/повторный запрос не создаёт непредусмотренный дубль; capacity/availability и статусные переходы сохраняют исходные ограничения.
- anon не может подтвердить, отменить или изменить чужую бронь.

### События и регистрация
- Список и детали показывают только `is_active=true AND show_on_home=true`.
- Скрытое/неактивное событие недоступно в публичном RPC и прямом SELECT anon.
- Регистрация anon создаётся без привязки к чужому аккаунту по введённому телефону.
- Auth user связывается только с `auth.uid()`, когда телефон подтверждён и нормализованное значение совпадает.
- Существующий ненулевой `user_id` никогда не перезаписывается.
- Проверить лимиты имени, телефона, количества участников, email, комментария и суммы.

### Платежи и финансы
- Только успешные allocations считаются оплаченными/собранными; pending не уменьшают долг.
- Платёж и allocation создаются ровно один раз; проверить повторный submit/повтор RPC.
- Не допускается распределение сверх суммы платежа без явно определённого бизнес-контракта.
- Отмена/возврат не переписывает исходный платёж: отдельная reversal-модель, если она реализована.
- Не менять исторические `paid_amount`, balances, debts и связи пользователей в рамках этого security rollout.
- Сравнить baseline и итог: количество записей, суммы успешных платежей, суммы успешных allocations, pending, orphan allocations и mismatch отчёт.

## 5. Verification, rollback и выходные артефакты

Для каждой группы сохранить:
- SQL output каждого `*_verification.sql`;
- before/after definitions, owners, grants, RLS и policy diff;
- результат allow/deny по каждому актору;
- браузерные smoke tests: public rooms, booking, event list/registration, profile, purchases, admin booking, kitchen, guest profile, finance, events, services, space;
- advisor baseline/delta и объяснение каждого нового предупреждения;
- контрольные финансовые агрегаты и проверку сохранности user_id;
- rollback log на отдельном disposable staging snapshot, затем повторное применение миграции и повторные тесты.

Rollback-файлы могут восстанавливать прежний authorization guard и не должны рассматриваться как безопасная production-стратегия. Сначала проверить их на disposable staging, зафиксировать ожидаемую потерю/откат функциональности и убедиться, что они не открывают anon/PUBLIC доступ. Для триггеров account-linking использовать сохранённые точные pre-change определения; универсальный inverse SQL не придумывать.

## 6. Production go/no-go — все условия обязательны

- [ ] Подтверждён отдельный staging project/ref; ни один тест не выполнялся на production.
- [ ] Snapshot/backup создан, restore rehearsal успешен.
- [ ] Все migration prerequisites соблюдены; роль owner/admin назначена только тестовым аккаунтам на staging.
- [ ] Все verification SQL прошли без ошибок.
- [ ] Все positive и negative role tests пройдены, включая user-A/user-B isolation.
- [ ] Все публичные формы и admin UI smoke tests прошли.
- [ ] Нет необъяснённых финансовых расхождений, дублей, потери user_id или изменения исторических сумм.
- [ ] Security Advisors delta просмотрен; каждое новое предупреждение объяснено.
- [ ] Rollback rehearsal завершён и повторное применение проверено.
- [ ] Caller inventory и Edge Function compatibility закрыты.
- [ ] Отдельно утверждены production backup, окно, миграционный порядок, ответственный и план отката.
- [ ] Получено явное одобрение пользователя на production rollout.

Пока хотя бы один пункт не закрыт, статус — **NO-GO**. Текущий статус: **NO-GO** — staging не подтверждён, SQL и браузерные staging-тесты не запускались, production не изменялся.
