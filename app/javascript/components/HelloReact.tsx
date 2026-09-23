import React from "react";

type Props = {
  name: string;
};

export default function HelloReact({ name }: Props) {
  return (
    <div className="rounded-lg bg-neutral-100 p-4 text-sm text-neutral-800">
      Olá, {name}! (renderizado via React)
    </div>
  );
}
