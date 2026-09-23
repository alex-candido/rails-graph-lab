import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "form", "empty"]

  submit(event) {
    event.preventDefault()

    const question = this.inputTarget.value.trim()
    if (!question) return

    this.hideEmptyState()
    this.appendUserMessage(question)
    const pendingId = this.appendPendingMessage()

    this.inputTarget.value = ""
    this.inputTarget.disabled = true

    fetch(this.formTarget.action, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": this.csrfToken(),
      },
      body: new URLSearchParams({ question }),
    })
      .then((response) => response.json())
      .then((data) => this.poll(data.id, pendingId))
      .catch(() => this.showError(pendingId, "Não consegui enviar a pergunta."))
  }

  poll(id, pendingId) {
    fetch(`/chat/questions/${id}`, { headers: { Accept: "application/json" } })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "completed") {
          this.showAnswer(pendingId, data)
        } else if (data.status === "failed") {
          this.showError(pendingId, data.erro || "Algo deu errado.")
        } else {
          setTimeout(() => this.poll(id, pendingId), 1000)
        }
      })
      .catch(() => this.showError(pendingId, "Não consegui consultar a resposta."))
  }

  showAnswer(pendingId, data) {
    const bubble = this.messagesTarget.querySelector(`[data-pending-id="${pendingId}"]`)
    if (!bubble) return

    const assuntos = (data.assuntos_consultados || "")
      .split(",")
      .map((nome) => nome.trim())
      .filter(Boolean)

    bubble.innerHTML = `
      <div class="text-sm leading-relaxed text-neutral-800 dark:text-neutral-100 whitespace-pre-line">${this.escape(data.resposta)}</div>
      ${assuntos.length ? this.renderTags(assuntos) : ""}
    `

    this.inputTarget.disabled = false
    this.inputTarget.focus()
    this.scrollToBottom()
  }

  showError(pendingId, message) {
    const bubble = this.messagesTarget.querySelector(`[data-pending-id="${pendingId}"]`)
    if (bubble) {
      bubble.innerHTML = `<div class="text-sm text-red-600 dark:text-red-400">${this.escape(message)}</div>`
    }

    this.inputTarget.disabled = false
    this.inputTarget.focus()
  }

  renderTags(assuntos) {
    const tags = assuntos
      .map(
        (nome) =>
          `<span class="inline-flex items-center rounded-full bg-blue-50 dark:bg-blue-500/10 px-3 py-1 text-xs font-medium text-blue-700 dark:text-blue-300">${this.escape(nome)}</span>`
      )
      .join("")

    return `<div class="mt-3 flex flex-wrap gap-2">${tags}</div>`
  }

  appendUserMessage(question) {
    const row = document.createElement("div")
    row.className = "flex justify-end"
    row.innerHTML = `
      <div class="max-w-[75%] rounded-3xl rounded-br-md bg-blue-600 px-5 py-3 text-sm text-white">
        ${this.escape(question)}
      </div>
    `
    this.messagesTarget.appendChild(row)
    this.scrollToBottom()
  }

  appendPendingMessage() {
    const pendingId = crypto.randomUUID()
    const row = document.createElement("div")
    row.className = "flex justify-start"
    row.innerHTML = `
      <div class="max-w-[75%] rounded-3xl rounded-bl-md bg-neutral-100 dark:bg-neutral-800 px-5 py-3" data-pending-id="${pendingId}">
        <div class="flex gap-1">
          <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-neutral-400 [animation-delay:-0.3s]"></span>
          <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-neutral-400 [animation-delay:-0.15s]"></span>
          <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-neutral-400"></span>
        </div>
      </div>
    `
    this.messagesTarget.appendChild(row)
    this.scrollToBottom()

    return pendingId
  }

  hideEmptyState() {
    if (this.hasEmptyTarget) this.emptyTarget.classList.add("hidden")
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  escape(text) {
    const div = document.createElement("div")
    div.textContent = text || ""
    return div.innerHTML
  }
}
