# FreeDom — визуальный аудит страниц

## Текущий статус
**VISUAL AUDIT: BLOCKED / NOT COMPLETED.** В имеющихся командных отчётах нет подтверждённых актуальных скриншотов текущего code SHA. Анализ CSS/HTML не является визуальным аудитом. Старый READY Preview не покрывает последний известный кодовый SHA.

## Матрица захвата
Для каждой страницы получить реальные скриншоты с указанием Preview URL, deployment ID, commit SHA, даты и viewport.

| Страница | 390×844 | 768×1024 | 1440×900 | Приоритет |
|---|---|---|---|---|
| Главная / Orbit | pending | pending | pending | P1 |
| Пространство | pending | pending | pending | P1 |
| Комнаты | pending | pending | pending | P1 |
| Кухня | pending | pending | pending | P1 |
| События | pending | pending | pending | P2 |
| Баня | pending | pending | pending | P2 |
| История | pending | pending | pending | P2 |
| Регистрация / вход | pending | pending | pending | P1 |
| Профиль / партнёры / покупки | pending | pending | pending | P1 |
| Бронирование | pending | pending | pending | P1 |

## Что фиксировать на каждом экране
- Композиция, визуальная иерархия, баланс пустого пространства.
- Overflow, clipping, перекрытие текста и интерактивных зон.
- Реальный размер шрифта, line-height, ширина текстовой колонки.
- Отступы, сетка, размеры карточек и hit targets.
- Контраст, читаемость поверх фотографий, focus-visible.
- Кадрирование изображений, качество и layout shift.
- Скачки/вспышки старых фонов при навигации.
- Поведение при scroll, resize, orientation change.
- Hover, focus, active, loading, empty, error и success.
- Reduced Motion и доступность клавиатуры.

## Реестр дефектов
Для каждого дефекта:
- ID:
- Page / component:
- Exact viewport:
- Reproduction steps:
- Screenshot before:
- Expected:
- Actual:
- Severity P0–P3:
- Root cause confidence:
- Suggested fix:
- Acceptance criteria:
- Owner role:
- Commit SHA:
- Screenshot after:
- QA status:

## Правило
Не создавать визуальные дефекты на основании догадки о CSS. Если визуального доказательства нет, пометить HYPOTHESIS и запросить скриншот/браузерный доступ. Не выставлять VISUAL PASS до сравнения реального экрана с требованиями.


## Проверка доступности HTML Preview — 17.11.2026

Проверен Vercel Preview:
- URL: https://freed-6dekucaox-sergeyogorodnik19-3325s-projects.vercel.app/
- Deployment: `dpl_F3z9YMDZBpmdPmjX34sf5FxkYKLR`
- Exact commit SHA: `cb930a2a5f8165f599d5b0f49c70cefd356039fd`
- Vercel state: READY.
- HTML fetch: HTTP 200 для всех 11 маршрутов ниже.

| Route | HTTP | Document title | Visual/browser QA |
|---|---:|---|---|
| / | 200 | FreeDom — дом, в котором живет любовь | NOT RUN |
| /space.html | 200 | Пространство — FreeDom | NOT RUN |
| /rooms-eco-futurism-v2.html | 200 | FreeDom Rooms — Nature Interface | NOT RUN |
| /kitchen-pixel-v2.html | 200 | FreeDom — Кухня | NOT RUN |
| /freedom-banya-v2.html | 200 | FreeDom — Баня | NOT RUN |
| /freedom-events-v1.html | 200 | FreeDom — События | NOT RUN |
| /project-history.html | 200 | FreeDom — История проекта | NOT RUN |
| /register.html | 200 | Регистрация — FreeDom | NOT RUN |
| /login.html | 200 | Вход — FreeDom | NOT RUN |
| /profile.html | 200 | Личный кабинет — FreeDom | NOT RUN |
| /availability_map_v3.html | 200 | FreeDom — выбор размещения | NOT RUN |

HTTP 200 подтверждает только получение HTML-документа. Не подтверждает загрузку всех assets, выполнение JavaScript, доступность API, отсутствие console errors, визуальную композицию или успешность интерактивных сценариев. Скриншоты реальных viewport пока не получены. Browser/Android QA остаётся NOT RUN.
