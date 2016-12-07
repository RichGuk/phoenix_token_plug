defmodule PhoenixTokenPlug.EnsureAuthenticated do
  @moduledoc """
  Ensures the verification by `PhoenixTokenPlug.VerifyHeader`
  of the request was successful by checking the existence of
  `conn.assigns.user`.

  If one is not found, the `unauthenticated/2` function of the
  passed handler is invoked with the `Plug.Conn.t` object and
  its params.

  ## Usage

  Add this to your `router.ex`, possibly inside a pipeline:

      plug PhoenixTokenPlug.EnsureAuthenticated,
        handler: MyApp.AuthController  # Or whatever module you want

  Then, in your `MyApp.AuthController`:

      defmodule MyApp.AuthController do
        # ...

        def unauthenticated(conn, _params) do
          conn
          |> put_status(401)
          |> json(%{error: "Unauthenticated!"})
        end

        # ...
      end

  You might pass several options to the plugs:

      plug PhoenixTokenPlug.EnsureAuthenticated,
        handler: MyApp.AuthController  # (required) The handler module
        key: :foo                      # (optional) Customize lookup key for conn.assigns, defaults to :user
  """

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, opts) do
    handler = Keyword.get(opts, :handler)
    key = Keyword.get(opts, :key, :user)
    case conn.assigns[key] do
      nil ->
        conn = conn |> halt
        apply(handler, :unauthenticated, [conn, conn.params])
      _ ->
        conn
    end
  end

end
