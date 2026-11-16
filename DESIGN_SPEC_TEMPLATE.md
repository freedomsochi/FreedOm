# Design Specification — шаблон передачи дизайна

> Заполняется для каждой существенной визуальной задачи. Все значения маркируются как MEASURED (измерено по референсу), PROPOSED (предложение дизайнера) или UNKNOWN (неизвестно). Не выдавать предложенные размеры за текущие параметры сайта.

## 1. Паспорт
- Task ID:
- Страница / URL:
- Компонент:
- Рабочая ветка / базовый SHA:
- Дата:
- Автор:
- Цель изменения:
- Причина / подтверждённый дефект:
- Приоритет:
- Зависимости:

## 2. Визуальные доказательства
- Исходный скриншот: ссылка/путь, viewport, дата, SHA Preview.
- Целевой референс: ссылка/путь.
- Состояние страницы: initial / hover / focus / active / expanded / loading / empty / error / success.
- Если скриншота или браузерного доступа нет: явно написать VISUAL REVIEW BLOCKED. Кодовый анализ не считать визуальной проверкой.

## 3. Геометрия и сетка
Для каждого элемента:
| Element / selector | Desktop | Tablet | Mobile | Status |
|---|---|---|---|---|
| Container width | | | | MEASURED/PROPOSED/UNKNOWN |
| Height / min-height | | | | |
| Position / alignment | | | | |
| Grid columns / gap | | | | |
| Padding / margin | | | | |
| Border radius | | | | |
| Z-index / overlap | | | | |

Единицы: CSS px для фиксированных деталей; rem для масштабируемой типографики/интервалов; %, vw, vh, clamp() для fluid layout. Не использовать сантиметры как основную единицу веб-макета.

## 4. Цветовая система
| Token | HEX/RGBA | Opacity | Назначение | Status |
|---|---|---:|---|---|
| --color-primary | | | | |
| --color-secondary | | | | |
| --color-accent | | | | |
| --color-background | | | | |
| --color-surface | | | | |
| --color-text | | | | |
| --color-muted | | | | |
| --color-border | | | | |
| --color-focus | | | | |

Проверить контраст текста, focus indicator и состояния disabled. Палитру брать из утверждённой дизайн-системы или явно предлагать на согласование.

## 5. Типографика
| Элемент | Font family | Size | Weight | Line-height | Letter spacing | Color |
|---|---|---:|---:|---:|---:|---|
| H1 | | | | | | |
| H2 | | | | | | |
| Body | | | | | | |
| Caption | | | | | | |
| Button | | | | | | |

Указать fallback fonts, переносы строк, max-width текста и поведение при увеличении системного масштаба.

## 6. Изображения и медиа
- Asset path / exact filename:
- Aspect ratio:
- Object-fit / object-position:
- Crop focal point:
- Loading / fallback:
- Alt text:
- Mobile-specific crop:
- Проверка резкости, размера файла и отсутствия скачка layout.

## 7. Поверхности и эффекты
- Background / gradients:
- Blur / backdrop-filter:
- Border:
- Shadow (x, y, blur, spread, color):
- Glow:
- Opacity:
- Слои и порядок наложения:
- Ограничения производительности на мобильных устройствах.

## 8. Поведение и motion
| Trigger | From state | To state | Duration | Easing | Reduced motion |
|---|---|---|---:|---|---|
| Hover | | | | | |
| Click/tap | | | | | |
| Swipe/drag | | | | | |
| Scroll | | | | | |
| Keyboard | | | | | |

Описать focus, Escape, outside click, повторное нажатие, отмену жеста, блокировку scroll, prefers-reduced-motion и touch target.

## 9. Адаптивность
Минимум проверить/описать:
- Mobile: 360–430 CSS px.
- Tablet: около 768 CSS px.
- Desktop: 1280–1440 CSS px.
- Дополнительные реальные размеры по скриншотам.
Указать breakpoint и причину его выбора; не плодить новые breakpoint без необходимости.

## 10. Контент и локализация
- Точный текст:
- Максимальная длина:
- Переносы:
- Пустые/длинные значения:
- Язык и fallback:

## 11. Критерии приёмки
- [ ] Геометрия соответствует спецификации в указанных viewport.
- [ ] Текст не перекрывается и не обрезается.
- [ ] Все состояния описаны и проверены.
- [ ] Изображения корректно кадрируются и не вызывают layout shift.
- [ ] Контраст и клавиатурный фокус приемлемы.
- [ ] Reduced Motion соблюдён.
- [ ] Нет регрессии соседних компонентов.
- [ ] Есть before/after screenshots с точным SHA.
- [ ] Static/build/browser статусы записаны отдельно.

## 12. Передача программисту
- Разрешённые файлы:
- Запрещённые файлы/системы:
- Предпочтительный способ реализации:
- Не менять бизнес-логику:
- План отката:
- Неясности, требующие решения владельца:
- Отличия от спецификации, требующие повторного согласования:
