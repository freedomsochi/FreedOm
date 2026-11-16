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
