# Componentização com Phlex

> **Ao criar qualquer layout, tela ou UI, priorize a componentização que o `phlex-rails` oferece.** Antes de escrever HTML/ERB inline, verifique se já existe um componente reutilizável e prefira criar/estender componentes Phlex.

## Convenções existentes

- Todo componente herda de `Components::Base` (`app/components/base.rb`), que inclui os helpers Phlex/Rails (rotas, `link_to`, `image_tag`, etc.).
- **Componentes base reutilizáveis** ficam em `app/components/base/` — ex.: `Button`, `Card`, `StatCard`, `Table`, `Tag`, `TextInput`, `Icon`, `FlashMessage`, `Level`, `FieldDetails`. Reaproveite-os em vez de duplicar markup.
- **Layouts** ficam em `app/components/layouts/` (ex.: `DashboardLayout`, `AuthLayout`) e são usados como layout do controller:
  ```ruby
  layout -> { Components::Layouts::DashboardLayout.new(user: Current.user, current_path: request.path) }
  ```
- Componentes de navegação/estrutura: `Navbar`, `Sidebar`, `SidebarItem`.
- Padrão de um componente: `initialize` recebe parâmetros nomeados; lógica de classes/variantes em métodos privados; renderização em `view_template`. Estilos via classes Tailwind, com variantes parametrizadas (ver `Components::Base::Button` como referência de `variant`/`size`).

## Ao construir uma nova tela

1. Componha a partir dos componentes base existentes em `app/components/base/`.
2. Crie novos componentes em `app/components/base/` quando o elemento for reutilizável.
3. Mantenha layouts em `app/components/layouts/`.
