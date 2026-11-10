"use client";

import { useState, type FormEvent } from "react";
import { useEveAgent } from "eve/react";
import { WEB_CHAT_AGENT } from "./eve-agent";

export default function Home() {
  const agent = useEveAgent({ agent: WEB_CHAT_AGENT });
  const [draft, setDraft] = useState("");
  const isResuming = agent.status === "resuming";

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const message = draft.trim();
    if (!message || isResuming) return;
    setDraft("");
    void agent.send(message);
  };

  const errorText = agent.error
    ? agent.error instanceof Error
      ? agent.error.message
      : "Не удалось выполнить запрос. Попробуйте ещё раз."
    : null;

  return (
    <main className="page">
      <header className="topbar">
        <div className="brand">FreeDom</div>
        <div className="status">Внутренняя AI-команда</div>
      </header>

      <section className="intro">
        <div className="eyebrow">КОМАНДА РАЗРАБОТКИ</div>
        <h1>Одно большое ТЗ.<br />Четыре специалиста. Один результат.</h1>
        <p className="intro-copy">
          Опишите задачу своими словами. Координатор распределит работу между
          дизайнером, техническим программистом, моушн-дизайнером и тестировщиком,
          а затем соберёт общий результат.
        </p>
      </section>

      <section className="workspace" aria-label="Рабочий чат FreeDom">
        <div className="messages" aria-live="polite">
          {agent.messages.length === 0 ? (
            <div className="empty">
              <div className="empty-mark">✦</div>
              <h2>С чего начнём?</h2>
              <p>
                Можно отправить одно большое техническое задание на несколько
                страниц и процессов. Команда сначала согласует план, затем приступит
                к реализации и проверке.
              </p>
            </div>
          ) : (
            agent.messages.map((message) => (
              <article
                key={message.id}
                className={`message ${message.role === "assistant" ? "assistant" : "user"}`}
              >
                <div className="message-label">
                  {message.role === "assistant" ? "FreeDom AI" : "Вы"}
                </div>
                {message.parts.map((part, index) =>
                  part.type === "text" ? <p key={index}>{part.text}</p> : null,
                )}
              </article>
            ))
          )}
        </div>

        {errorText ? <p className="error" role="alert">{errorText}</p> : null}

        <form className="composer" onSubmit={submit}>
          <textarea
            value={draft}
            onChange={(event) => setDraft(event.currentTarget.value)}
            placeholder="Опишите задачу для команды FreeDom…"
            aria-label="Текст задания"
            disabled={isResuming}
          />
          <div className="composer-footer">
            <span>{agent.status === "busy" ? "Команда работает…" : "Отправьте задачу одним сообщением"}</span>
            <div className="actions">
              {agent.status === "busy" ? (
                <button className="stop" type="button" onClick={() => void agent.cancel()}>
                  Остановить
                </button>
              ) : null}
              <button className="send" type="submit" disabled={!draft.trim() || isResuming}>
                Отправить
              </button>
            </div>
          </div>
        </form>
      </section>

      <footer className="footer">
        Доступ только через Vercel Authentication команды проекта.
      </footer>
    </main>
  );
}
