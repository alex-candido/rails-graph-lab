import React, { useRef, useState } from "react"

type Status = "pending" | "processing" | "completed" | "failed"

type ChatQuestion = {
  id: number
  question: string
  status: Status
  resposta: string | null
  assuntos_consultados: string | null
  erro: string | null
}

type Message = {
  id: string
  role: "user" | "assistant"
  text?: string
  assuntos?: string[]
  pending?: boolean
  error?: boolean
}

type Props = {
  createPath: string
}

function csrfToken(): string {
  return document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content || ""
}

export default function Chat({ createPath }: Props) {
  const [messages, setMessages] = useState<Message[]>([])
  const [question, setQuestion] = useState("")
  const [sending, setSending] = useState(false)
  const messagesRef = useRef<HTMLDivElement>(null)

  const scrollToBottom = () => {
    requestAnimationFrame(() => {
      messagesRef.current?.scrollTo({ top: messagesRef.current.scrollHeight })
    })
  }

  const poll = (id: number, pendingId: string) => {
    fetch(`${createPath}/${id}`, { headers: { Accept: "application/json" } })
      .then((response) => response.json())
      .then((data: ChatQuestion) => {
        if (data.status === "completed") {
          setMessages((prev) =>
            prev.map((message) =>
              message.id === pendingId
                ? {
                    ...message,
                    pending: false,
                    text: data.resposta ?? "",
                    assuntos: (data.assuntos_consultados || "")
                      .split(",")
                      .map((nome) => nome.trim())
                      .filter(Boolean),
                  }
                : message
            )
          )
          scrollToBottom()
        } else if (data.status === "failed") {
          setMessages((prev) =>
            prev.map((message) =>
              message.id === pendingId
                ? { ...message, pending: false, error: true, text: data.erro || "Algo deu errado." }
                : message
            )
          )
        } else {
          setTimeout(() => poll(id, pendingId), 1000)
        }
      })
      .catch(() => {
        setMessages((prev) =>
          prev.map((message) =>
            message.id === pendingId
              ? { ...message, pending: false, error: true, text: "Não consegui consultar a resposta." }
              : message
          )
        )
      })
  }

  const submit = (event: React.FormEvent) => {
    event.preventDefault()

    const trimmed = question.trim()
    if (!trimmed || sending) return

    const pendingId = crypto.randomUUID()

    setMessages((prev) => [
      ...prev,
      { id: crypto.randomUUID(), role: "user", text: trimmed },
      { id: pendingId, role: "assistant", pending: true },
    ])
    setQuestion("")
    setSending(true)
    scrollToBottom()

    fetch(createPath, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": csrfToken(),
      },
      body: new URLSearchParams({ question: trimmed }),
    })
      .then((response) => response.json())
      .then((data: ChatQuestion) => {
        setSending(false)
        poll(data.id, pendingId)
      })
      .catch(() => {
        setSending(false)
        setMessages((prev) =>
          prev.map((message) =>
            message.id === pendingId
              ? { ...message, pending: false, error: true, text: "Não consegui enviar a pergunta." }
              : message
          )
        )
      })
  }

  return (
    <div className="flex h-full flex-col">
      <header className="flex items-center gap-2 px-6 py-4">
        <div className="h-7 w-7 rounded-full bg-gradient-to-tr from-blue-500 via-violet-500 to-pink-400" />
        <span className="text-lg font-medium text-neutral-700 dark:text-neutral-200">Fabi Graph Lab</span>
      </header>

      <div className="mx-auto flex w-full max-w-3xl flex-1 flex-col overflow-hidden px-4">
        {messages.length === 0 && (
          <div className="flex flex-1 flex-col items-center justify-center gap-2">
            <h1 className="bg-gradient-to-r from-blue-500 via-violet-500 to-pink-400 bg-clip-text text-4xl font-medium text-transparent">
              Olá, o que você quer entender hoje?
            </h1>
            <p className="text-neutral-500 dark:text-neutral-400">
              Pergunte sobre pré-requisitos e assuntos do grafo de conhecimento.
            </p>
          </div>
        )}

        <div ref={messagesRef} className="flex-1 space-y-4 overflow-y-auto py-6">
          {messages.map((message) => (
            <div key={message.id} className={`flex ${message.role === "user" ? "justify-end" : "justify-start"}`}>
              {message.role === "user" ? (
                <div className="max-w-[75%] rounded-3xl rounded-br-md bg-blue-600 px-5 py-3 text-sm text-white">
                  {message.text}
                </div>
              ) : (
                <div className="max-w-[75%] rounded-3xl rounded-bl-md bg-neutral-100 px-5 py-3 dark:bg-neutral-800">
                  {message.pending ? (
                    <div className="flex gap-1">
                      <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-neutral-400 [animation-delay:-0.3s]" />
                      <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-neutral-400 [animation-delay:-0.15s]" />
                      <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-neutral-400" />
                    </div>
                  ) : (
                    <>
                      <div
                        className={`whitespace-pre-line text-sm leading-relaxed ${
                          message.error ? "text-red-600 dark:text-red-400" : "text-neutral-800 dark:text-neutral-100"
                        }`}
                      >
                        {message.text}
                      </div>
                      {!!message.assuntos?.length && (
                        <div className="mt-3 flex flex-wrap gap-2">
                          {message.assuntos.map((nome) => (
                            <span
                              key={nome}
                              className="inline-flex items-center rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700 dark:bg-blue-500/10 dark:text-blue-300"
                            >
                              {nome}
                            </span>
                          ))}
                        </div>
                      )}
                    </>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      <div className="mx-auto w-full max-w-3xl px-4 pb-6">
        <form onSubmit={submit}>
          <div className="flex items-center gap-2 rounded-full border border-neutral-200 bg-neutral-50 px-5 py-3 shadow-sm focus-within:border-blue-400 dark:border-neutral-700 dark:bg-neutral-800">
            <input
              type="text"
              value={question}
              onChange={(event) => setQuestion(event.target.value)}
              autoComplete="off"
              disabled={sending}
              className="flex-1 bg-transparent text-sm text-neutral-800 placeholder-neutral-400 focus:outline-none disabled:opacity-50 dark:text-neutral-100"
              placeholder="Ex: o que eu preciso saber antes de entender Funções?"
            />
            <button
              type="submit"
              disabled={sending}
              className="flex h-8 w-8 items-center justify-center rounded-full bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="h-4 w-4">
                <path d="M3.478 2.404a.75.75 0 0 0-.926.94l2.432 7.905H13.5a.75.75 0 0 1 0 1.5H4.984l-2.432 7.905a.75.75 0 0 0 .926.94 60.519 60.519 0 0 0 18.445-8.986.75.75 0 0 0 0-1.218A60.517 60.517 0 0 0 3.478 2.404Z" />
              </svg>
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
