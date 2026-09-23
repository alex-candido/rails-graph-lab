import { Controller } from "@hotwired/stimulus"
import React from "react"
import { createRoot, Root } from "react-dom/client"

import HelloReact from "../components/HelloReact"
import Chat from "../components/Chat"

const modules: Record<string, React.ComponentType<any>> = {
  HelloReact,
  Chat,
}

export default class extends Controller {
  static values = {
    component: String,
    props: Object,
  }

  declare readonly componentValue: string
  declare readonly propsValue: Record<string, unknown>

  root?: Root

  connect() {
    const module = modules[this.componentValue]
    if (!module) {
      console.error(`react_controller: componente "${this.componentValue}" não encontrado`)
      return
    }

    this.root = createRoot(this.element)
    this.root.render(React.createElement(module, this.propsValue))
  }

  disconnect() {
    this.root?.unmount()
  }
}
