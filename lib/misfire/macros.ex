defmodule Misfire.Macros do
  defmacro __using__(_) do
    quote do: import Misfire.Macros
  end

  # Examples
  #
  #     ensure_protocol(protocol)
  #     |> if_ok(change_debug_info(types))
  #     |> if_ok(compile)
  #
  defmacro if_ok(expr, call) do
    var = quote do: var
    quote do
      case unquote(expr) do
        { :ok, unquote(var) } -> unquote(Macro.pipe(var, call))
        other -> other
      end
    end
  end

  # Examples
  #
  #     pipe_matching { :ok, x }, x,
  #        ensure_protocol(protocol)
  #     |> change_debug_info(types)
  #     |> compile
  #
  defmacro pipe_matching(expr, var, pipes) do
    Enum.reduce Macro.unpipe(pipes), fn x, acc ->
      quote do
        case unquote(acc) do
          unquote(expr) -> unquote(Macro.pipe(var, x))
          error -> error
        end
      end
    end
  end
end